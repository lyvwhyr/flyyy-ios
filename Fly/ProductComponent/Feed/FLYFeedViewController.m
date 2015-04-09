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
#import "FLYSingleGroupViewController.h"
#import "FLYInlineReplyView.h"
#import "FLYTopicDetailViewController.h"
#import "FLYBarButtonItem.h"
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

#define kMaxWaitForTableLoad 3

@interface FLYFeedViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, FLYFeedTopicTableViewCellDelegate>

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) FLYInlineReplyView *inlineReplyView;
@property (nonatomic) UITableView *feedTableView;

//used for pagination load more
@property (nonatomic) NSString *beforeTimestamp;
@property (nonatomic) NSInteger loadMoreCount;

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
        [self _addObservers];
    }
    return self;
}

- (void)_addObservers
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = LOC(@"FLYHomeTitle");
    
    _posts = [NSMutableArray new];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (![self hideLeftBarItem]) {
        [self _loadLeftBarItem];
    }
    [self _addInlineReplyBar];
    
    _feedTableView = [UITableView new];
    _feedTableView.backgroundColor = [UIColor clearColor];
    _feedTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _feedTableView.dataSource = self;
    _feedTableView.delegate = self;
    [_feedTableView registerClass:[FLYFeedTopicTableViewCell class] forCellReuseIdentifier:@"feedPostCellIdentifier"];
    [self.view addSubview:_feedTableView];
    
    _feedTableView.separatorInset = UIEdgeInsetsZero;
    _feedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _feedTableView.scrollsToTop = YES;
    
    _backgroundView = [UIView new];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundView];
    
    [self _initService];
    
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:nil component:nil element:nil action:@"impression"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // load feed onboarding view
    _checkOnboardingCellLoadedTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(_checkCellAvailability) userInfo:nil repeats:YES];
}

#pragma mark - service

- (void)_initService
{
    @weakify(self)
    [_feedTableView addPullToRefreshWithActionHandler:^{
        @strongify(self)
        [self _load:YES before:nil];
    }];
    
    [self.feedTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO before:self.beforeTimestamp];
    }];
    [self _load:YES before:nil];
}

- (void)_load:(BOOL)first before:(NSString *)before
{
    self.state = FLYViewControllerStateLoading;
    if (self.topicService == nil) {
        self.topicService = [[FLYTopicService alloc] initWithEndpoint:@"topics"];
    }
    
    @weakify(self)
    FlYGetTopicsSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
        NSArray *topicsArray = responseObj;
        
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
            [self.posts addObject:topic];
        }
        //Set up before id for load more
        FLYTopic *lastTopic = [self.posts lastObject];
        self.beforeTimestamp = lastTopic.createdAt;
        [self.feedTableView reloadData];
    };
    FLYGetTopicsErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        self.state = FLYViewControllerStateError;
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    };
    if (first || before) {
        [self.topicService nextPageBefore:before firstPage:first successBlock:successBlock errorBlock:errorBlock];
    } else {
        [self.topicService nextPageBefore:before firstPage:YES successBlock:successBlock errorBlock:errorBlock];
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _clearAllPlaying];
}

- (void)_addInlineReplyBar
{
    _inlineReplyView = [FLYInlineReplyView new];
    _inlineReplyView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weakSelf = self;
    _inlineReplyView.backgroudTappedBlock = ^(FLYInlineReplyView *view){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _moveInlineReplyViewOffScreen];
    };
    [self.view addSubview:_inlineReplyView];
}

- (void)_loadLeftBarItem
{
    FLYCatalogBarButtonItem *leftBarItem = [FLYCatalogBarButtonItem barButtonItem:YES];
    leftBarItem.actionBlock = ^(FLYBarButtonItem *item) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideRecordIconNotification object:self];
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        FLYMeViewController *vc = [FLYMeViewController new];
        [self.flyNavigationController pushViewController:vc animated:YES];
    };
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (![self isFullScreen]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecordIconNotification object:self];
    }
    
    if ([self isFullScreen]) {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    } else {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    }
    
    // This is a hack. When you go to home feed, tap on group name and go to group page. Tap on play and quickly navigate back
    // to home feed, the play button on home feed is in the wrong state. It is because GroupViewController extends from
    // FeedViewController and the audio item is the same.
    NSArray *visibleCells = [self.feedTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        FLYFeedTopicTableViewCell *visibleCell = (FLYFeedTopicTableViewCell *)(visibleCells[i]);
        [visibleCell updatePlayState:FLYPlayStateNotSet];
    }
}

- (void)updateViewConstraints
{
    [_backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_feedTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_inlineReplyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(CGRectGetHeight(self.view.bounds));
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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
        FLYMainViewController *mainVC = nil;
        if (self.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[FLYMainViewController class]]) {
            mainVC = (FLYMainViewController *)self.parentViewController.parentViewController;
        }
        
        [FLYFeedOnBoardingView showFeedOnBoardViewWithCellToExplain:cell mainVC:mainVC];
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

- (void)groupNameTapped:(FLYFeedTopicTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    FLYGroup *group = ((FLYTopic *)self.posts[indexPath.row]).group;
    FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:group];
    vc.isFullScreen = [self isFullScreen];
    [self.flyNavigationController pushViewController:vc animated:YES];
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

#pragma mark - reply view move in and off screen
- (void)_moveInlineReplyViewOnScreen
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_inlineReplyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.3f animations:^{
        _backgroundView.backgroundColor = [UIColor grayColor];
        _backgroundView.alpha = 0.4;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (void)_moveInlineReplyViewOffScreen
{
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.alpha = 0;
    [self.view bringSubviewToFront:_backgroundView];
    [_inlineReplyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(CGRectGetHeight(self.view.bounds));
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
    [self.view needsUpdateConstraints];
    [self.view layoutIfNeeded];
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

@end
