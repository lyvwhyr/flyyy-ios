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

@interface FLYTopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, FLYTopicDetailTopicCellDelegate, FLYTopicDetailReplyCellDelegate, FLYAudioManagerDelegate>

@property (nonatomic) UITableView *topicTableView;

@property (nonatomic) FLYTopic *topic;
@property (nonatomic) NSMutableArray *replies;

@property (nonatomic) BOOL setLayoutConstraints;

//used for reply pagination
@property (nonatomic) NSString *beforeTimestamp;

@end

@implementation FLYTopicDetailViewController

#define kFlyTopicDetailViewControllerTopicCellIdentifier @"flyTopicDetailViewControllerTopicCellIdentifier"
#define kFlyTopicDetailViewControllerReplyCellIdentifier @"flyTopicDetailViewControllerReplyCellIdentifier"

- (instancetype)initWithTopic:(FLYTopic *)topic
{
    if (self = [super init]) {
        _topic = topic;
        _replies = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newReplyReceived:) name:kNewReplyReceivedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_downloadComplete:)
                                                     name:kDownloadCompleteNotification object:nil];
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
    [self.topicTableView registerClass:[FLYTopicDetailTopicCell class] forCellReuseIdentifier:kFlyTopicDetailViewControllerTopicCellIdentifier];
    [self.topicTableView registerClass:[FLYTopicDetailReplyCell class] forCellReuseIdentifier:kFlyTopicDetailViewControllerReplyCellIdentifier];
    [self.view addSubview:_topicTableView];
    
    [self _loadReplies];
    
    [[FLYScribe sharedInstance] logEvent:@"topic_detail" section:nil component:nil element:nil action:@"impression"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_topicTableView reloadData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
        cell = (FLYFeedTopicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FLYFeedTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor flyBlue];
        ((FLYTopicDetailTopicCell *)cell).delegate = self;
        [((FLYTopicDetailTopicCell *)cell) setupTopic:self.topic];
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
        return [FLYTopicDetailTopicCell cellHeightForTopic:self.topic];
    }
    return 90;
}

- (void)_loadReplies
{
    //partialUrl = [NSString stringWithFormat:@"topics?limit=%d&before=%@", kTopicPaginationCount, self.beforeTimestamp];
    NSString *baseURL = [NSString stringWithFormat: @"topics/%@?limit=%d", self.topic.topicId, KReplyPaginationCount];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *results = responseObject;
        NSArray *repliesArray = [results objectForKey:@"replies"];
        
        for(int i = 0; i < repliesArray.count; i++) {
            FLYReply *reply = [[FLYReply alloc] initWithDictionary:repliesArray[i]];
            [self.replies addObject:reply];
        }
        //Set up before id for load more
        FLYReply *lastReply = [self.replies lastObject];
        self.beforeTimestamp = lastReply.createdAt;
        [self.topicTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
}

#pragma mark - FLYTopicDetailTopicCellDelegate
- (void)commentButtonTapped:(FLYTopicDetailTopicCell *)cell
{
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForReply];
    recordViewController.topicId = self.topic.topicId;
    UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - FLYTopicDetailReplyCellDelegate
- (void)replyToReplyButtonTapped:(FLYReply *)reply
{
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForReply];
    recordViewController.topicId = self.topic.topicId;
    recordViewController.parentReplyId = reply.replyId;
    UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

- (void)playReply:(FLYReply *)reply indexPath:(NSIndexPath *)indexPath
{
    [[FLYDownloadManager sharedInstance] loadAudioByURLString:reply.mediaURL audioType:FLYDownloadableReply];
    
//    self.audioController.url = [NSURL URLWithString:reply.mediaURL];
//    [self.audioController play];
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
        FLYBlueBackBarButtonItem *barItem = [FLYBlueBackBarButtonItem barButtonItem:YES];
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
    return [UIColor whiteColor];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor whiteColor];
}

@end
