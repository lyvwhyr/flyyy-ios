//
//  FLYTopicDetailViewController.m
//  Fly
//
//  Created by Xingxing Xu on 12/6/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTopicDetailViewController.h"
#import "FLYBarButtonItem.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYTopicDetailReplyCell.h"
#import "FLYBarButtonItem.h"
#import "UIColor+FLYAddition.h"
#import "FLYTopic.h"
#import "FLYTopicDetailReplyCell.h"
#import "FLYTopicDetailTopicCell.h"
#import "FLYRecordViewController.h"
#import "FLYNavigationController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FLYReply.h"
#import "FLYAudioStateManager.h"
#import "AEAudioFilePlayer.h"
#import "FLYDownloadManager.h"
#import "FLYAudioManager.h"
#import "FLYReplyService.h"
#import "SVPullToRefresh.h"
#import "FLYTopicDetailTabbar.h"
#import "FLYFeedTopicTableViewCell.h"

@interface FLYTopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, FLYTopicDetailTopicCellDelegate, FLYTopicDetailReplyCellDelegate, FLYAudioManagerDelegate, FLYTopicDetailTabbarDelegate, FLYFeedTopicTableViewCellDelegate>

@property (nonatomic) UITableView *topicTableView;
@property (nonatomic) FLYTopicDetailTabbar *tabbar;

@property (nonatomic) FLYTopic *topic;
@property (nonatomic) NSMutableArray *replies;

@property (nonatomic) BOOL setLayoutConstraints;

//used for reply pagination
@property (nonatomic) NSString *beforeTimestamp;

//services
@property (nonatomic) FLYReplyService *replyService;

@end

@implementation FLYTopicDetailViewController

#define kFlyTopicDetailViewControllerTopicCellIdentifier @"flyTopicDetailViewControllerTopicCellIdentifier"
#define kFlyTopicDetailViewControllerReplyCellIdentifier @"flyTopicDetailViewControllerReplyCellIdentifier"

- (instancetype)initWithTopic:(FLYTopic *)topic
{
    if (self = [super init]) {
        _topic = topic;
        _replies = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_newReplyReceived:)
                                                     name:kNewReplyPostedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_downloadComplete:)
                                                     name:kDownloadCompleteNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithTopicId:(NSString *)topicId
{
    return self;
}

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topicTableView = [UITableView new];
    self.topicTableView.delegate = self;
    self.topicTableView.dataSource = self;
    self.topicTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.topicTableView registerClass:[FLYFeedTopicTableViewCell class] forCellReuseIdentifier:kFlyTopicDetailViewControllerTopicCellIdentifier];
    [self.topicTableView registerClass:[FLYTopicDetailReplyCell class] forCellReuseIdentifier:kFlyTopicDetailViewControllerReplyCellIdentifier];
    [self.view addSubview:self.topicTableView];
    
    self.tabbar = [FLYTopicDetailTabbar new];
    self.tabbar.delegate = self;
    [self.view addSubview:self.tabbar];
    
    [self _initService];
    
    [[FLYScribe sharedInstance] logEvent:@"topic_detail" section:nil component:nil element:nil action:@"impression"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_topicTableView reloadData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [FLYUtilities printAutolayoutTrace];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[FLYAudioManager sharedInstance].audioPlayer stop];
}

- (void)updateViewConstraints
{
    if (!_setLayoutConstraints) {
        _setLayoutConstraints = YES;
        CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight;
        [_topicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
            make.leading.equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.equalTo(@(tableViewHeight));
        }];
        
        [self.tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.height.equalTo(@(44));
        }];
        
    }
    
    [super updateViewConstraints];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateViewConstraints];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : _replies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == FlyTopicCellSectionIndex) {
        static NSString *cellIdentifier = kFlyTopicDetailViewControllerTopicCellIdentifier;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        BOOL needUpdateConstraints = YES;
        if (cell == nil) {
            needUpdateConstraints = NO;
            cell = [[FLYFeedTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLYFeedTopicTableViewCell *topicCell = (FLYFeedTopicTableViewCell *)cell;
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            topicCell.contentView.frame = cell.bounds;
            topicCell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        }
        topicCell.backgroundColor = [UIColor clearColor];
        //set cell state
        [topicCell updatePlayState:FLYPlayStateNotSet];
        if ([[FLYAudioStateManager sharedInstance].currentPlayItem.indexPath isEqual:indexPath]) {
            [topicCell updatePlayState:[FLYAudioStateManager sharedInstance].currentPlayItem.playState];
        }
        topicCell.topic = self.topic;
        topicCell.indexPath = indexPath;
        [topicCell setupTopic:self.topic needUpdateConstraints:needUpdateConstraints];
        topicCell.selectionStyle = UITableViewCellSelectionStyleNone;
        topicCell.delegate = self;
        cell = topicCell;
    } else {
        static NSString *cellIdentifier = kFlyTopicDetailViewControllerReplyCellIdentifier;
        cell = (FLYTopicDetailReplyCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FLYTopicDetailReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ((FLYTopicDetailReplyCell *)cell).delegate = self;
        ((FLYTopicDetailReplyCell *)cell).indexPath = indexPath;
        [((FLYTopicDetailReplyCell *)cell) setupReply:self.replies[indexPath.row]];
    }
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FlyTopicCellSectionIndex) {
        return 90;
    }
    return 80;
}


#pragma mark - services
- (void)_initService
{
    self.replyService = [FLYReplyService replyServiceWithTopicId:self.topic.topicId];
    [self _load:YES before:nil];
    @weakify(self)
    [self.topicTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO before:self.beforeTimestamp];
    }];
}

- (void)_load:(BOOL)first before:(NSString *)before
{
    @weakify(self)
    FLYReplyServiceGetRepliesSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.topicTableView.infiniteScrollingView stopAnimating];
        NSDictionary *results = responseObj;
        NSArray *repliesArray = [results objectForKey:@"replies"];
        
        self.state = FLYViewControllerStateReady;
        if (first) {
            [self.replies removeAllObjects];
        }
        
        for(int i = 0; i < repliesArray.count; i++) {
            FLYReply *reply = [[FLYReply alloc] initWithDictionary:repliesArray[i]];
            [self.replies addObject:reply];
        }
        //Set up before id for load more
        FLYReply *lastReply = [self.replies lastObject];
        self.beforeTimestamp = lastReply.createdAt;
        [self.topicTableView reloadData];
    };
    FLYReplyServiceGetRepliesErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        [self.topicTableView.infiniteScrollingView stopAnimating];
    };
    [self.replyService nextPage:before firstPage:first successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark - FLYTopicDetailTopicCellDelegate
- (void)commentButtonTapped:(FLYTopicDetailTopicCell *)cell
{
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForReply];
    recordViewController.topic = self.topic;
    UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - FLYTopicDetailReplyCellDelegate
- (void)replyToReplyButtonTapped:(FLYReply *)reply
{
    [self _commentButtonTapped];
}

- (void)playReply:(FLYReply *)reply indexPath:(NSIndexPath *)indexPath
{
    [[FLYDownloadManager sharedInstance] loadAudioByURLString:reply.mediaURL audioType:FLYDownloadableReply];
}

#pragma mark - FLYTopicDetailTabbarDelegate

- (void)commentButtonOnTabbarTapped:(id)sender
{
    [self _commentButtonTapped];
}

- (void)playAllButtonOnTabbarTapped:(id)sender
{
    
}

- (void)_commentButtonTapped
{
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForReply];
    recordViewController.topic = self.topic;
    UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}


# pragma mark - FLYTopicDetailReplyCellDelegate

- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)tappedCell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Notification

- (void)_newReplyReceived:(NSNotification *)notif
{
    FLYReply *reply = [notif.userInfo objectForKey:kNewReplyKey];
    [self.replies insertObject:reply atIndex:0];
    [self.topicTableView reloadData];
    [self _scrollToTop];
}

- (void)_downloadComplete:(NSNotification *)notif
{
    FLYDownloadableAudioType type = [[notif.userInfo objectForKey:kDownloadAudioTypeKey] integerValue];
    if(type != FLYDownloadableReply) {
        return;
    }
    
    NSString *localPath = [notif.userInfo objectForKey:kDownloadAudioLocalPathkey];
    [[FLYAudioManager sharedInstance] playAudioWithURLStr:localPath itemType:FLYPlayableItemDetailReply];
}

- (void)_scrollToTop
{
    NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.topicTableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - Navigation bar
- (void)loadLeftBarButton
{
    if ([self.navigationController.viewControllers count] > 1) {
        FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _backButtonTapped];
        };
        self.navigationItem.leftBarButtonItem = barItem;
    }
}

#pragma mark - Navigation bar
- (void)loadRightBarButton
{
    FLYFlagTopicBarButtonItem *barItem = [FLYFlagTopicBarButtonItem barButtonItem:NO];
    __weak typeof(self)weakSelf = self;
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        
    };
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)_backButtonTapped
{
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    [self.view layoutIfNeeded];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}

@end
