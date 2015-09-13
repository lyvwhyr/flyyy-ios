//
//  FLYFeedViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FLYFeedViewController.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYFilterHomeFeedSelectorViewController.h"
#import "FLYTopicDetailViewController.h"
#import "FLYGroupViewController.h"
#import "FLYDownloadManager.h"
#import "FLYTopic.h"
#import "SVPullToRefresh.h"
#import "UIColor+FLYAddition.h"
#import "AFHTTPRequestOperationManager.h"
#import "Dialog.h"
#import "STKAudioPlayer.h"
#import "FLYAudioItem.h"
#import "FLYDownloadableAudio.h"
#import "FLYGroup.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYTopicService.h"
#import "FLYCatalogViewController.h"
#import "FLYAudioManager.h"
#import "FLYMeViewController.h"
#import "FLYFeedOnBoardingView.h"
#import "SDiPhoneVersion.h"
#import "FLYMainViewController.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYPushNotificationManager.h"
#import "FLYUser.h"
#import "SCLAlertView.h"
#import "UIColor+FLYAddition.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYShareManager.h"
#import "UIBarButtonItem+Badge.h"
#import "FLYSegmentedFeedViewController.h"
#import "NSTimer+BlocksKit.h"

#define kMaxWaitForTableLoad 3

#define kPopPushNotificationDialogSessionCount 2
#define kHomeTimelineViewCountAfterLoginKey @"kHomeTimelineViewCountAfterLoginKey"

@interface FLYFeedViewController () <UITableViewDelegate, UITableViewDataSource, FLYFeedTopicTableViewCellDelegate>

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UITableView *feedTableView;

//used for pagination load more
@property (nonatomic) NSString *beforeTimestamp;
@property (nonatomic) NSInteger loadMoreCount;
@property (nonatomic) NSString *cursor;

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) BOOL didSetConstraints;

// check if a tableview is full loaded for so we can launch on boarding
@property (nonatomic) CGFloat elapsedTimeSinceLastCellSeen;
@property (nonatomic) NSTimer *checkOnboardingCellLoadedTimer;

@end

@implementation FLYFeedViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadComplete:)
                                                     name:kDownloadCompleteNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_newPostReceived:)
                                                     name:kNewPostReceivedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_topicDeleted:)
                                                     name:kNotificationTopicDeleted object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_audioPlayStateChanged:)
                                                     name:kNotificationAudioPlayStateChanged object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_audioFinishedPlaying:)
                                                     name:kNotificationDidFinishPlaying object:nil];
        
        _loadMoreCount = 0;
        _feedType = FLYFeedTypeHome;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = LOC(@"FLYHomeTitle");
    
    _posts = [NSMutableArray new];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _feedTableView = [UITableView new];
    _feedTableView.backgroundColor = [UIColor clearColor];
    _feedTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _feedTableView.dataSource = self;
    _feedTableView.delegate = self;
    [_feedTableView registerClass:[FLYFeedTopicTableViewCell class] forCellReuseIdentifier:@"feedPostCellIdentifier"];
    [self.view addSubview:_feedTableView];
    
    _feedTableView.separatorInset = UIEdgeInsetsZero;
    _feedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    _feedTableView.scrollsToTop = YES;
    
    _backgroundView = [UIView new];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundView];
    
    [self _initService];
    
    NSDictionary *properties = @{kTrackingSection: @"post_page", kTrackingComponent:@"post",  kTrackingElement:@"post_button", kTrackingAction:@"click"};
    [[Mixpanel sharedInstance]  track:@"home_page" properties:properties];
    
    [self updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // load feed onboarding view
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasSeenFeedOnboarding = [[defaults objectForKey:kFeedOnboardingKey] boolValue];
    if (!hasSeenFeedOnboarding) {
        _checkOnboardingCellLoadedTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_checkCellAvailability) userInfo:nil repeats:YES];
    }
    
    @weakify(self)
    FLYServiceVersion version = [self.topicService serviceVersion:self.topicService.endpoint];
    [_feedTableView addPullToRefreshWithActionHandler:^{
        @strongify(self)
        if (version == FLYServiceVersionOne) {
            [self _load:YES before:nil cursor:NO];
        } else {
            [self _load:YES before:nil cursor:YES];
        }
    }];
}

#pragma mark - service

- (void)_initService
{
    if (self.topicService == nil) {
        self.topicService = [[FLYTopicService alloc] initWithEndpoint:EP_TOPIC_V2];
    }
    
    FLYServiceVersion version = [self.topicService serviceVersion:self.topicService.endpoint];
    
    @weakify(self)
    [self.feedTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        if (version == FLYServiceVersionOne) {
            [self _load:NO before:self.beforeTimestamp cursor:NO];
        } else {
            [self _load:NO before:self.cursor cursor:YES];
        }
    }];
    
    if (version == FLYServiceVersionOne) {
        [self _load:YES before:nil cursor:NO];
    } else {
        [self _load:YES before:self.cursor cursor:YES];
    }
}

- (void)_load:(BOOL)first before:(NSString *)before cursor:(BOOL)useCursor
{
    // No more to fetch
    if (!first && useCursor && !before) {
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    self.state = FLYViewControllerStateLoading;
    @weakify(self)
    FLYGetTopicsSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
        
        NSArray *topicsArray;
        if (!useCursor) {
            topicsArray = responseObj;
        } else {
            topicsArray = [responseObj fly_arrayForKey:@"topics"];
            self.cursor = [responseObj fly_stringForKey:@"cursor"];
            if (!self.cursor || [self.cursor isEqualToString:@""]) {
                self.cursor = nil;
            }
        }
        
        if (topicsArray == nil ||  topicsArray.count == 0) {
            self.state = FLYViewControllerStateError;
            return;
        }
        
        self.state = FLYViewControllerStateReady;
        if (first) {
            [self.posts removeAllObjects];
        }
        
        for(int i = 0; i < topicsArray.count; i++) {
            FLYTopic *topic = [[FLYTopic alloc] initWithDictory:topicsArray[i]];
            // ignore duplicate
            if ([self _isPostInArray:topic]) {
                continue;
            }
            [self.posts addObject:topic];
        }
        //Set up before id for load more
        FLYTopic *lastTopic = [self.posts lastObject];
        self.beforeTimestamp = lastTopic.createdAt;
        [self.feedTableView reloadData];
//        [self updateViewConstraints];
    };
    FLYGetTopicsErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        self.state = FLYViewControllerStateError;
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    };
    if (first || before) {
        [self.topicService nextPageBefore:before firstPage:first cursor:useCursor successBlock:successBlock errorBlock:errorBlock];
    } else {
        [self.topicService nextPageBefore:before firstPage:YES cursor:useCursor successBlock:successBlock errorBlock:errorBlock];
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _clearAllPlaying];
}

- (void)_popPushNotificationDialogIfNecessary
{
    // pop enable push notification dialog on 2rd session
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger timelineViewCount = [defaults integerForKey:kHomeTimelineViewCountAfterLoginKey];
    if (timelineViewCount >= kPopPushNotificationDialogSessionCount) {
        // enable push notification dialog
        [self performSelector:@selector(_showEnablePushNotifDialog) withObject:self afterDelay:0.5];
    }
    timelineViewCount += 1;
    [defaults setInteger:timelineViewCount forKey:kHomeTimelineViewCountAfterLoginKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownPNDialog = [defaults boolForKey:kHasShownEnablePushNotificationDialog];
    if (hasShownPNDialog) {
        [FLYPushNotificationManager registerPushNotification];
    }
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // This is a hack. When you go to home feed, tap on group name and go to group page. Tap on play and quickly navigate back
    // to home feed, the play button on home feed is in the wrong state. It is because GroupViewController extends from
    // FeedViewController and the audio item is the same.
    NSArray *visibleCells = [self.feedTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
        [visibleCell updatePlayState:FLYPlayStateNotSet];
    }
    
    [self _popPushNotificationDialogIfNecessary];
}

- (void)updateViewConstraints
{
    [_backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if (self.feedType == FLYFeedTypeGroup || self.feedType == FLYFeedTypeMine) {
        [_feedTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    } else {
        [_feedTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
    [super updateViewConstraints];
}


- (void)_filterButtonTapped
{
    FLYFilterHomeFeedSelectorViewController *vc = [FLYFilterHomeFeedSelectorViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d_%@", @"feedPostCellIdentifier", (int)indexPath.section, (int)indexPath.row, NSStringFromClass([self class])];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
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
    if (([FLYAudioManager sharedInstance].currentPlayItem.itemType == FLYPlayableItemFeedTopic) && [[FLYAudioManager sharedInstance].currentPlayItem.indexPath isEqual:indexPath]) {
        [topicCell updatePlayState:[FLYAudioManager sharedInstance].currentPlayItem.playState];
    }
    topicCell.topic = _posts[indexPath.row];
    topicCell.indexPath = indexPath;
    if (self.feedType == FLYFeedTypeGroup) {
        topicCell.options |= FLYTopicCellOptionGroupName;
    }
    [topicCell setupTopic:_posts[indexPath.row] needUpdateConstraints:needUpdateConstraints];
    topicCell.selectionStyle = UITableViewCellSelectionStyleNone;
    topicCell.delegate = self;
    [topicCell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return topicCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FLYFeedTopicTableViewCell heightForTopic:_posts[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideRecordIconNotification object:self];
    
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.view layoutIfNeeded];
    FLYTopic *topic = self.posts[indexPath.row];
    FLYTopicDetailViewController *viewController = [[FLYTopicDetailViewController alloc] initWithTopic:topic];
    viewController.isBackFullScreen = [self isFullScreen];
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // stop previous. same cell.
    if (![[FLYAudioManager sharedInstance].previousPlayItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem] && [FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemFeedTopic && [indexPath isEqual:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]) {
            [self clearPreviousPlayingItem];
    }
    
    if (![indexPath isEqual:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]) {
        FLYFeedTopicTableViewCell *displayedCell = (FLYFeedTopicTableViewCell *)cell;
        [displayedCell updatePlayState:FLYPlayStateNotSet];
    }
    
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}


#pragma mark - Onboarding
- (void)_checkCellAvailability
{
    _elapsedTimeSinceLastCellSeen += 0.05;
    if (_elapsedTimeSinceLastCellSeen >= kMaxWaitForTableLoad) {
        [self _cleanupOnBoardingTimer];
    }
    
    NSIndexPath *indexPathToOnboarding;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        indexPathToOnboarding = [NSIndexPath indexPathForRow:1 inSection:0];
    } else {
        indexPathToOnboarding = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    FLYFeedTopicTableViewCell *cell = (FLYFeedTopicTableViewCell *)([self.feedTableView cellForRowAtIndexPath:indexPathToOnboarding]);
    if (cell) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(YES) forKey:kFeedOnboardingKey];
        [defaults synchronize];
        
        FLYMainViewController *mainVC = nil;
        if (self.parentViewController && [self.parentViewController.parentViewController.parentViewController isKindOfClass:[FLYMainViewController class]]) {
            mainVC = (FLYMainViewController *)self.parentViewController.parentViewController.parentViewController;
        }
        
        [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
            [FLYFeedOnBoardingView showFeedOnBoardViewWithCellToExplain:cell mainVC:mainVC];
        } repeats:NO];
        [self _cleanupOnBoardingTimer];
    }
}

- (void)_cleanupOnBoardingTimer
{
    [_checkOnboardingCellLoadedTimer invalidate];
    _checkOnboardingCellLoadedTimer = nil;
    _elapsedTimeSinceLastCellSeen = 0;
}


#pragma mark - notification

- (void)downloadComplete:(NSNotification *)notificaiton
{
    NSString *localPath = [notificaiton.userInfo objectForKey:kDownloadAudioLocalPathkey];
    if([FLYAudioManager sharedInstance].currentPlayItem.itemType != FLYPlayableItemFeedTopic) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
        NSURL* url = [NSURL fileURLWithPath:localPath];
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [[FLYAudioManager sharedInstance].audioPlayer setDataSource:dataSource withQueueItemId:[FLYAudioManager sharedInstance].currentPlayItem];
    });
}

- (void)_newPostReceived:(NSNotification *)notif
{
    FLYTopic *topic = [notif.userInfo objectForKey:kNewPostKey];
    [self.posts insertObject:topic atIndex:0];
    [self.feedTableView reloadData];
    [self _scrollToTop];
    
    // enable push notification dialog
    [self performSelector:@selector(_showEnablePushNotifDialog) withObject:self afterDelay:0.5];
}

- (void)_showEnablePushNotifDialog
{
    [FLYPushNotificationManager showEnablePushNotificationDialog:self];
}

- (void)_topicDeleted:(NSNotification *)notif
{
    FLYTopic *topic = [notif.userInfo objectForKey:@"topic"];
    [self.posts removeObject:topic];
    [self.feedTableView reloadData];
}

- (void)_audioPlayStateChanged:(NSNotification *)notif
{
    FLYAudioItem *currentItem = [FLYAudioManager sharedInstance].currentPlayItem;
    if (currentItem.itemType != FLYPlayableItemFeedTopic) {
        return;
    }
    
    FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *) [self.feedTableView cellForRowAtIndexPath:currentItem.indexPath];
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


- (void)_audioFinishedPlaying:(NSNotification *)notif
{
    NSInteger stopReason = [[notif.userInfo objectForKey:kAudioStopReasonKey] integerValue];
    FLYAudioItem *queueItemId = [notif.userInfo objectForKey:kAudioItemkey];
    
    
    if (stopReason == STKAudioPlayerStopReasonEof) {
        // stop current
        if([FLYAudioManager sharedInstance].currentPlayItem && [FLYAudioManager sharedInstance].currentPlayItem.itemType == FLYPlayableItemFeedTopic && [[FLYAudioManager sharedInstance].currentPlayItem.indexPath isEqual:queueItemId.indexPath]) {
            FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *)([self.feedTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateNotSet;
            [currentCell updatePlayState:FLYPlayStateNotSet];
        }
    }
    
    // stop previous
    if ([FLYAudioManager sharedInstance].previousPlayItem && [FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemFeedTopic) {
        [self clearPreviousPlayingItem];
    }
}

- (void)_scrollToTop
{
    NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.feedTableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - FLYFeedTopicTableViewCellDelegate
- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell
{
    [self tableView:self.feedTableView didSelectRowAtIndexPath:cell.indexPath];
}

- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)tappedCell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath
{
    // clear the reset of the cells
    NSArray *visibleCells = [self.feedTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
        if (visibleCell.indexPath != tappedCell.indexPath) {
            [visibleCell updatePlayState:FLYPlayStateNotSet];
        }
    }
    
    FLYAudioItem *newItem = [[FLYAudioItem alloc] initWithUrl:[NSURL URLWithString:post.mediaURL] andCount:0 indexPath:indexPath itemType:FLYPlayableItemFeedTopic playState:FLYPlayStateNotSet audioDuration:post.audioDuration];
    
    if ([newItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem]) {
        newItem = [FLYAudioManager sharedInstance].currentPlayItem;
    }
    
    [[FLYAudioManager sharedInstance] updateAudioState:newItem];
}

- (void)groupNameTapped:(FLYFeedTopicTableViewCell *)cell indexPath:(NSIndexPath *)indexPath tagId:(NSString *)tagId
{
    NSMutableArray *tags = ((FLYTopic *)self.posts[indexPath.row]).tags;
    FLYGroup *tappedTag;
    for (FLYGroup *tag in tags) {
        if ([tag.groupId isEqualToString:tagId]) {
            tappedTag = tag;
            break;
        }
    }
    if (tappedTag) {
        FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:tappedTag];
        vc.isFullScreen = [self isFullScreen];
        [self.flyNavigationController pushViewController:vc animated:YES];
 
    }
}

- (void)clearPreviousPlayingItem
{
    if (![FLYAudioManager sharedInstance].previousPlayItem) {
        return;
    }
    
    FLYFeedTopicTableViewCell *previousPlayingCell = (FLYFeedTopicTableViewCell *)([self.feedTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
    [FLYAudioManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
    [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
}

- (void)_clearAllPlaying
{
    if ([FLYAudioManager sharedInstance].previousPlayItem) {
        FLYFeedTopicTableViewCell *previousPlayingCell = (FLYFeedTopicTableViewCell *)([self.feedTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
        [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
        [FLYAudioManager sharedInstance].previousPlayItem = nil;
    }
    
    if ([FLYAudioManager sharedInstance].currentPlayItem) {
        FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *)([self.feedTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
        [currentCell updatePlayState:FLYPlayStateNotSet];
        [FLYAudioManager sharedInstance].currentPlayItem = nil;
    }
    
    // clear the reset of the cells
    NSArray *visibleCells = [self.feedTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
        [visibleCell updatePlayState:FLYPlayStateNotSet];
    }
    
    [[FLYAudioManager sharedInstance].audioPlayer stop];
}

- (UINavigationController *)navigationController
{
    if ([self.delegate rootViewController]) {
        return [self.delegate rootViewController].navigationController;
    } else {
        return [super navigationController];
    }
}

#pragma mark - navigation bar item tapped 
- (void)_autoPlayButtonTapped
{
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}

- (void)_profileButtonTapped
{
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
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

- (BOOL)hideLeftBarItem
{
    return NO;
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

#pragma mark - Helper method to test if a post is already in posts array or not
- (BOOL)_isPostInArray:(FLYTopic *)topic
{
    if ([self.posts count] == 0) {
        return NO;
    }
    for (int i = 0; i < self.posts.count; i++) {
        FLYTopic *postInArray = self.posts[i];
        if ([topic isEqual:postInArray]) {
            return YES;
        }
    }
    return NO;
}

@end
