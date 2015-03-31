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
#import "FLYAudioStateManager.h"
#import "FLYPlayableItem.h"
#import "UIColor+FLYAddition.h"
#import "AFHTTPRequestOperationManager.h"
#import "Dialog.h"
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"
#import "FLYDownloadableAudio.h"
#import "FLYGroup.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYTopicService.h"
#import "FLYCatalogViewController.h"

@interface FLYFeedViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, FLYFeedTopicTableViewCellDelegate, STKAudioPlayerDelegate>

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) FLYInlineReplyView *inlineReplyView;
@property (nonatomic) UITableView *feedTableView;

//used for pagination load more
@property (nonatomic) NSString *beforeTimestamp;
@property (nonatomic) NSInteger loadMoreCount;

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) BOOL didSetConstraints;
@property (nonatomic) enum RequestType requestType;

@property (nonatomic) STKAudioPlayer *audioPlayer;


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
        
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        _audioPlayer.meteringEnabled = YES;
        _audioPlayer.volume = 1;
        _audioPlayer.delegate = self;
        
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
    if (![self isKindOfClass:[FLYGroupViewController class]]) {
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
    
//    _feedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    };
    if (first || before) {
        [self.topicService nextPageBefore:before firstPage:first successBlock:successBlock errorBlock:errorBlock];
    } else {
        [self.feedTableView.pullToRefreshView stopAnimating];
        [self.feedTableView.infiniteScrollingView stopAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearCurrentPlayingItem];
    [self.audioPlayer stop];
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
        self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
//        [self.view layoutIfNeeded];
        FLYCatalogViewController *vc = [FLYCatalogViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    };
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecordIconNotification object:self];
//    [self updateViewConstraints];
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"feedPostCellIdentifier", (int)indexPath.section, (int)indexPath.row];
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
//    [topicCell updatePlayState:FLYPlayStateNotSet];
    if ([[FLYAudioStateManager sharedInstance].currentPlayItem.indexPath isEqual:indexPath]) {
        [topicCell updatePlayState:[FLYAudioStateManager sharedInstance].currentPlayItem.playState];
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
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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


#pragma mark - notification

- (void)downloadComplete:(NSNotification *)notificaiton
{
    NSString *localPath = [notificaiton.userInfo objectForKey:kDownloadAudioLocalPathkey];
    FLYDownloadableAudioType type = [[notificaiton.userInfo objectForKey:kDownloadAudioTypeKey] integerValue];
    if(type != FLYDownloadableTopic) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
        NSURL* url = [NSURL fileURLWithPath:localPath];
        
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        
        [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0 indexPath:[FLYAudioStateManager sharedInstance].currentPlayItem.indexPath itemType:FLYPlayableItemFeedTopic]];
    });
}


#pragma mark - STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    NSLog(@"state change");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"error");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
    FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *) [self.feedTableView cellForRowAtIndexPath:[FLYAudioStateManager sharedInstance].currentPlayItem.indexPath];
    [currentCell updatePlayState:FLYPlayStatePlaying];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"finish buffering");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(SampleQueueId *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if ([FLYAudioStateManager sharedInstance].currentPlayItem.indexPath == queueItemId.indexPath && [FLYAudioStateManager sharedInstance].currentPlayItem.playState != FLYPlayStatePaused) {
         [self clearCurrentPlayingItem];
    }
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

- (void)_scrollToTop
{
    NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
    [self.feedTableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - FLYFeedTopicTableViewCellDelegate
- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell
{
     self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.view layoutIfNeeded];
    [self.view bringSubviewToFront:_inlineReplyView];
    [self _moveInlineReplyViewOnScreen];
    [self.view needsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)tappedCell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath
{
    
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"" component:post.topicId element:@"play_button" action:@"click"];
    
    //If currentPlayItem is empty, set the tappedCell as currentPlayItem
    NSIndexPath *tappedCellIndexPath;
    if (!indexPath) {
        tappedCellIndexPath = [self.feedTableView indexPathForCell:tappedCell];
    } else {
        tappedCellIndexPath = indexPath;
    }
    if (![FLYAudioStateManager sharedInstance].currentPlayItem) {
        [FLYAudioStateManager sharedInstance].currentPlayItem = [[FLYPlayableItem alloc] initWithItem:tappedCell playableItemType:FLYPlayableItemFeedTopic playState:FLYPlayStateNotSet indexPath:tappedCellIndexPath];
    }
    
    //tap on the same cell
    if ([FLYAudioStateManager sharedInstance].currentPlayItem.indexPath == tappedCellIndexPath) {
        if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStateNotSet) {
            [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStateLoading;
            [tappedCell updatePlayState:FLYPlayStateLoading];
            if (post.audioDuration < kStreamingMinimialLen) {
                [[FLYDownloadManager sharedInstance] loadAudioByURLString:post.mediaURL audioType:FLYDownloadableTopic];
            } else {
                NSURL* url = [NSURL URLWithString:post.mediaURL];
                STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
                [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0 indexPath:indexPath itemType:FLYPlayableItemFeedTopic]];
            }
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStateLoading) {
            return;
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStatePlaying) {
            [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStatePaused;
            [tappedCell updatePlayState:FLYPlayStatePaused];
            [_audioPlayer pause];
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStatePaused) {
            [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
            [_audioPlayer resume];
            [tappedCell updatePlayState:FLYPlayStateResume];
        }  else {
            [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStateFinished;
            [[FLYAudioStateManager sharedInstance] removePlayer];
            [tappedCell updatePlayState:FLYPlayStateFinished];
        }
        
        [FLYAudioStateManager sharedInstance].currentPlayItem.item = tappedCell;
    } else {
        //tap on a different cell
        //[[FLYAudioStateManager sharedInstance] removePlayer];
        if (post.audioDuration < kStreamingMinimialLen) {
            [[FLYDownloadManager sharedInstance] loadAudioByURLString:post.mediaURL audioType:FLYDownloadableTopic];
        } else {
            NSURL* url = [NSURL URLWithString:post.mediaURL];
            STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
            [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0 indexPath:indexPath itemType:FLYPlayableItemFeedTopic]];
        }
    
        //change previous state, remove animation, change current to previous
        [FLYAudioStateManager sharedInstance].previousPlayItem = [FLYAudioStateManager sharedInstance].currentPlayItem;
        [FLYAudioStateManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
        FLYFeedTopicTableViewCell *previousCell = (FLYFeedTopicTableViewCell *)[FLYAudioStateManager sharedInstance].previousPlayItem.item;
        [previousCell updatePlayState:FLYPlayStateNotSet];
    
        [FLYAudioStateManager sharedInstance].currentPlayItem =  [[FLYPlayableItem alloc] initWithItem:tappedCell playableItemType:FLYPlayableItemFeedTopic playState:FLYPlayStateLoading indexPath:tappedCellIndexPath] ;
        [tappedCell updatePlayState:FLYPlayStateLoading];
    }
}

- (void)groupNameTapped:(FLYFeedTopicTableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    FLYGroup *group = ((FLYTopic *)self.posts[indexPath.row]).group;
    FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:group];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearCurrentPlayingItem
{
    if (![FLYAudioStateManager sharedInstance].currentPlayItem) {
        [FLYAudioStateManager sharedInstance].previousPlayItem = nil;
        return;
    }
    FLYFeedTopicTableViewCell *currentPlayingCell = (FLYFeedTopicTableViewCell *)[FLYAudioStateManager sharedInstance].currentPlayItem.item;
    [currentPlayingCell updatePlayState:FLYPlayStateNotSet];
    
    [FLYAudioStateManager sharedInstance].previousPlayItem = [FLYAudioStateManager sharedInstance].currentPlayItem;
    [FLYAudioStateManager sharedInstance].currentPlayItem = nil;
}

#pragma mark - download audios
- (void)_autoDownloadAudios
{
    
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

@end
