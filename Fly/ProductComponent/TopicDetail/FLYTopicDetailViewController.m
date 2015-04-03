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
#import "AEAudioFilePlayer.h"
#import "FLYDownloadManager.h"
#import "FLYAudioManager.h"
#import "FLYReplyService.h"
#import "SVPullToRefresh.h"
#import "FLYTopicDetailTabbar.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"
#import "PXAlertView.h"
#import "Dialog.h"
#import "IBActionSheet.h"
#import "FLYUser.h"
#import "FLYTopicService.h"
#import "FLYReplyService.h"

@interface FLYTopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, FLYTopicDetailTopicCellDelegate, FLYTopicDetailReplyCellDelegate, FLYTopicDetailTabbarDelegate, FLYFeedTopicTableViewCellDelegate>

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

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_audioPlayStateChanged:)
                                                     name:kNotificationAudioPlayStateChanged
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_audioFinishedPlaying:)
                                                     name:kNotificationDidFinishPlaying object:nil];
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
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = LOC(@"FLYTopicDetailTitle");
    
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
    
    // There are 3 ways to navigatate back. We need to adjust navigation controller's frame.
    // 1). Back button click  2). Swipe back  3). A post is deleted
    // During swipe back, we pop the view directly so the bottom navigation bar will show immediately to avoid recording button and the other two buttons show at different time.
    [self.flyNavigationController.interactivePopGestureRecognizer addTarget:self
                                                                     action:@selector(_interactivePopGesture:)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [FLYUtilities printAutolayoutTrace];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[FLYAudioManager sharedInstance].audioPlayer stop];
    [self.flyNavigationController.interactivePopGestureRecognizer removeTarget:self action:nil];
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
//        [topicCell updatePlayState:FLYPlayStateNotSet];
        if ([[FLYAudioManager sharedInstance].currentPlayItem.indexPath isEqual:indexPath]) {
            [topicCell updatePlayState:[FLYAudioManager sharedInstance].currentPlayItem.playState];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //reply section tapped
    if (indexPath.section == 1) {
        [self _replyRowTapped:indexPath];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FlyTopicCellSectionIndex) {
        return [FLYFeedTopicTableViewCell heightForTopic:self.topic];
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
    [self _commentButtonTapped:reply];
}

- (void)playReply:(FLYReply *)reply indexPath:(NSIndexPath *)indexPath
{
    [[FLYDownloadManager sharedInstance] loadAudioByURLString:reply.mediaURL audioType:FLYDownloadableReply];
}

#pragma mark - FLYTopicDetailTabbarDelegate

- (void)commentButtonOnTabbarTapped:(id)sender
{
    [self _commentButtonTapped:nil];
}

- (void)playAllButtonOnTabbarTapped:(id)sender
{
    
}

- (void)_commentButtonTapped:(FLYReply *)reply
{
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForReply];
    if (reply) {
        if (![reply.user.userId isEqualToString:[FLYAppStateManager sharedInstance].currentUser.userId]) {
            recordViewController.parentReplyId = reply.replyId;
        }
    }
    FLYRecordingPermissionGrantedSuccessBlock successBlock = ^{
        recordViewController.topic = self.topic;
        UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    };
    
    [[FLYAudioManager sharedInstance] checkRecordingPermissionWithSuccessBlock:successBlock];
}


# pragma mark - FLYTopicDetailReplyCellDelegate

- (void)playButtonTapped:(FLYTopicDetailReplyCell *)tappedCell withReply:(FLYReply *)reply withIndexPath:(NSIndexPath *)indexPath
{
    // clear the reset of the cells
    NSArray *visibleCells = [self.topicTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        // topic cell
        if (indexPath.section == 0) {
            FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
            if (visibleCell.indexPath != tappedCell.indexPath) {
                [visibleCell updatePlayState:FLYPlayStateNotSet];
            }
        } else {
            // reply cell
            FLYTopicDetailReplyCell *visibleCell = (FLYTopicDetailReplyCell *)(visibleCells[i]);
            if (visibleCell.indexPath != tappedCell.indexPath) {
                [visibleCell updatePlayState:FLYPlayStateNotSet];
            }
        }
    }
    
    FLYAudioItem *newItem = [[FLYAudioItem alloc] initWithUrl:[NSURL URLWithString:reply.mediaURL] andCount:0 indexPath:indexPath itemType:FLYPlayableItemDetailReply playState:FLYPlayStateNotSet audioDuration:reply.audioDuration];
    
    if ([newItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem]) {
        newItem = [FLYAudioManager sharedInstance].currentPlayItem;
    }
    
    [[FLYAudioManager sharedInstance] updateAudioState:newItem];
}

- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)cell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath
{
    // clear the reset of the cells
    NSArray *visibleCells = [self.topicTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        // topic cell
        if (indexPath.section == 0) {
            FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
            if (visibleCell.indexPath != cell.indexPath) {
                [visibleCell updatePlayState:FLYPlayStateNotSet];
            }
        } else {
            // reply cell
            FLYTopicDetailReplyCell *visibleCell = (FLYTopicDetailReplyCell *)(visibleCells[i]);
            if (visibleCell.indexPath != cell.indexPath) {
                [visibleCell updatePlayState:FLYPlayStateNotSet];
            }
        }
    }
    
    FLYAudioItem *newItem = [[FLYAudioItem alloc] initWithUrl:[NSURL URLWithString:post.mediaURL] andCount:0 indexPath:indexPath itemType:FLYPlayableItemDetailTopic playState:FLYPlayStateNotSet audioDuration:post.audioDuration];
    
    if ([newItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem]) {
        newItem = [FLYAudioManager sharedInstance].currentPlayItem;
    }
    
    [[FLYAudioManager sharedInstance] updateAudioState:newItem];
}

#pragma mark - Notification

- (void)_newReplyReceived:(NSNotification *)notif
{
    FLYReply *reply = [notif.userInfo objectForKey:kNewReplyKey];
    [self.replies insertObject:reply atIndex:0];
    [self.topicTableView reloadData];
    [self _scrollToTop];
}

- (void)_downloadComplete:(NSNotification *)notificaiton
{
    if(([FLYAudioManager sharedInstance].currentPlayItem.itemType != FLYPlayableItemDetailTopic) && [FLYAudioManager sharedInstance].currentPlayItem.itemType != FLYPlayableItemDetailReply) {
        return;
    }
    NSString *localPath = [notificaiton.userInfo objectForKey:kDownloadAudioLocalPathkey];
    dispatch_async(dispatch_get_main_queue(), ^{
        [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
        NSURL* url = [NSURL fileURLWithPath:localPath];
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [[FLYAudioManager sharedInstance].audioPlayer setDataSource:dataSource withQueueItemId:[FLYAudioManager sharedInstance].currentPlayItem];
    });
}

- (void)_audioFinishedPlaying:(NSNotification *)notif
{
    NSInteger stopReason = [[notif.userInfo objectForKey:kAudioStopReasonKey] integerValue];
    FLYAudioItem *queueItemId = [notif.userInfo objectForKey:kAudioItemkey];
    
    if (stopReason == STKAudioPlayerStopReasonEof) {
        // stop current
        if([FLYAudioManager sharedInstance].currentPlayItem) {
            if ([FLYAudioManager sharedInstance].currentPlayItem.itemType == FLYPlayableItemDetailTopic && [FLYAudioManager sharedInstance].currentPlayItem.indexPath == queueItemId.indexPath) {
                FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *)([self.topicTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
                [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateNotSet;
                [currentCell updatePlayState:FLYPlayStateNotSet];
            } else if ([FLYAudioManager sharedInstance].currentPlayItem.itemType == FLYPlayableItemDetailReply && [FLYAudioManager sharedInstance].currentPlayItem.indexPath == queueItemId.indexPath){
                FLYTopicDetailReplyCell *currentCell = (FLYTopicDetailReplyCell *)([self.topicTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
                [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateNotSet;
                [currentCell updatePlayState:FLYPlayStateNotSet];
            }
        }
    }
    
    // stop previous
    if ([FLYAudioManager sharedInstance].previousPlayItem && ([FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemDetailTopic || [FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemDetailReply)) {
        [self _clearPreviousPlayingItem];
    }
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
    FLYOptionBarButtonItem *barItem = [FLYOptionBarButtonItem barButtonItem:NO];
    @weakify(self)
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _optionTapped];
    };
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)_backButtonTapped
{
    self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    [self.view layoutIfNeeded];
    [self.flyNavigationController popViewControllerAnimated:YES];
}


- (void)_optionTapped
{
    BOOL isAuthor = NO;
    if ([FLYAppStateManager sharedInstance].currentUser && [[FLYAppStateManager sharedInstance].currentUser.userId isEqualToString:self.topic.user.userId]) {
        isAuthor = YES;
    }
    
    NSMutableArray *otherButtons = [NSMutableArray new];
    [otherButtons addObject:LOC(@"FLYTopicDetailActionsheetReport")];
    if (isAuthor) {
        [otherButtons addObject:LOC(@"FLYTopicDetailActionsheetDeletePost")];
    }
    IBActionSheet *actionSheet = [[IBActionSheet alloc] initWithTitle:nil callback:^(IBActionSheet *actionSheet, NSInteger buttonIndex) {
        if (actionSheet.cancelButtonIndex != buttonIndex) {
            if (buttonIndex == 0) {
                [self _reportPost];
            } else if (buttonIndex == 1) {
                [self _deletePost];
            }
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitlesArray:otherButtons];
    [actionSheet showInView:self.view];
}

- (void)_reportReply:(FLYReply *)reply
{
    [PXAlertView showAlertWithTitle:LOC(@"FLYTopicDetailReportReplyTitle")
                            message:LOC(@"FLYTopicDetailReportReplyMessage")
                        cancelTitle:@"No"
                         otherTitle:@"Yes"
                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                             if (!cancelled && buttonIndex != 0) {
                                 [FLYReplyService reportReplyWithId:reply.replyId];
                                 [Dialog simpleToast:LOC(@"FLYTopicDetailReportReplySuccessTitle")];
                             }
                         }];
}

- (void)_reportPost
{
    [PXAlertView showAlertWithTitle:LOC(@"FLYTopicDetailReportPostTitle")
                            message:LOC(@"FLYTopicDetailReportPostMessage")
                        cancelTitle:@"No"
                         otherTitle:@"Yes"
                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                             if (!cancelled && buttonIndex != 0) {
                                 [FLYTopicService reportTopicWithId:self.topic.topicId];
                                 [Dialog simpleToast:LOC(@"FLYTopicDetailReportPostSuccessTitle")];
                             }
                         }];
}


- (void)_deletePost
{
    [PXAlertView showAlertWithTitle:LOC(@"FLYTopicDetailDeletePostAlertTitle")
                            message:LOC(@"FLYTopicDetailDeletePostAlertMessage")
                        cancelTitle:@"No"
                         otherTitle:@"Yes"
                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                             if (!cancelled && buttonIndex != 0) {

                                 [FLYTopicService deleteTopicWithId:self.topic.topicId successBlock:nil errorBlock:nil];
                                 
                                 NSDictionary *dict = @{@"topic":self.topic};
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTopicDeleted object:self userInfo:dict];
                                 [Dialog simpleToast:LOC(@"FLYTopicDetailDeletedHUD")];
                                 self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
                                 [self.flyNavigationController popViewControllerAnimated:YES];
                             }
                         }];
}

- (void)_deleteReply:(FLYReply *)reply
{
    [PXAlertView showAlertWithTitle:LOC(@"FLYTopicDetailActionsheetDeleteReply")
                            message:LOC(@"FLYTopicDetailDeleteReplyMessage")
                        cancelTitle:@"No"
                         otherTitle:@"Yes"
                         completion:^(BOOL cancelled, NSInteger buttonIndex) {
                             if (!cancelled && buttonIndex != 0) {
                                 [FLYReplyService deleteReplyWithId:reply.replyId successBlock:nil errorBlock:nil];
                                 [self.replies removeObject:reply];
                                 NSDictionary *dict = @{kNewReplyKey:reply, kTopicOfNewReplyKey:self.topic};
                                 [self.topic decrementReplyCount:dict];
                                 [self.topicTableView reloadData];
                             }
                         }];
}

- (void)_replyRowTapped:(NSIndexPath *)indexPath
{
    BOOL isAuthor = NO;
    FLYReply *reply = [self.replies objectAtIndex:indexPath.row];
    if ([FLYAppStateManager sharedInstance].currentUser && [[FLYAppStateManager sharedInstance].currentUser.userId isEqualToString:reply.user.userId]) {
        isAuthor = YES;
    }
    
    NSMutableArray *otherButtons = [NSMutableArray new];
    [otherButtons addObject:LOC(@"FLYTopicDetailActionsheetReportReply")];
    if (isAuthor) {
        [otherButtons addObject:LOC(@"FLYTopicDetailActionsheetDeleteReply")];
    }
    IBActionSheet *actionSheet = [[IBActionSheet alloc] initWithTitle:nil callback:^(IBActionSheet *actionSheet, NSInteger buttonIndex) {
        if (actionSheet.cancelButtonIndex != buttonIndex) {
            if (buttonIndex == 0) {
                [self _reportReply:reply];
            } else if (buttonIndex == 1) {
                [self _deleteReply:reply];
            }
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitlesArray:otherButtons];
    [actionSheet showInView:self.view];
}

- (void)_audioPlayStateChanged:(NSNotification *)notif
{
    FLYAudioItem *currentItem = [FLYAudioManager sharedInstance].currentPlayItem;
    if (currentItem.itemType == FLYPlayableItemDetailTopic) {
        FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *) [self.topicTableView cellForRowAtIndexPath:currentItem.indexPath];
        if (!currentCell) {
            return;
        }
        switch (currentItem.playState) {
            case FLYPlayStateLoading:{
                [currentCell updatePlayState:FLYPlayStateLoading];
                break;
            }
            case FLYPlayStatePlaying:{
                [currentCell updatePlayState:FLYPlayStatePlaying];
                break;
            }
            case FLYPlayStatePaused:{
                [currentCell updatePlayState:FLYPlayStatePaused];
                break;
            }
            case FLYPlayStateResume:{
                [currentCell updatePlayState:FLYPlayStateResume];
                break;
            }
            case FLYPlayStateFinished:{
                [currentCell updatePlayState:FLYPlayStateFinished];
                break;
            }
            default:
                break;
        }
    } else if(currentItem.itemType == FLYPlayableItemDetailReply) {
        FLYTopicDetailReplyCell *currentCell = (FLYTopicDetailReplyCell *) [self.topicTableView cellForRowAtIndexPath:currentItem.indexPath];
        if (!currentCell) {
            return;
        }
        switch (currentItem.playState) {
            case FLYPlayStateLoading:{
                [currentCell updatePlayState:FLYPlayStateLoading];
                break;
            }
            case FLYPlayStatePlaying:{
                [currentCell updatePlayState:FLYPlayStatePlaying];
                break;
            }
            case FLYPlayStatePaused:{
                [currentCell updatePlayState:FLYPlayStatePaused];
                break;
            }
            case FLYPlayStateResume:{
                [currentCell updatePlayState:FLYPlayStateResume];
                break;
            }
            case FLYPlayStateFinished:{
                [currentCell updatePlayState:FLYPlayStateFinished];
                break;
            }
            default:
                break;
        }

    }
}

- (void)_clearPreviousPlayingItem
{
    if (![FLYAudioManager sharedInstance].previousPlayItem) {
        return;
    }
    
    if ([FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemDetailTopic) {
        FLYFeedTopicTableViewCell *previousPlayingCell = (FLYFeedTopicTableViewCell *)([self.topicTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
        [FLYAudioManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
        [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
    } else if ([FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemDetailReply){
        FLYTopicDetailReplyCell *previousPlayingCell = (FLYTopicDetailReplyCell *)([self.topicTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
        [FLYAudioManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
        [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
    }
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

- (void)_interactivePopGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
        [self.view layoutIfNeeded];
        [self.flyNavigationController popViewControllerAnimated:YES];
    }
}

@end
