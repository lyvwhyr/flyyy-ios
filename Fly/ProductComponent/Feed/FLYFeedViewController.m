//
//  FLYFeedViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedViewController.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYNavigationBarMyGroupButton.h"
#import "FLYFilterHomeFeedSelectorViewController.h"
#import "FLYFeedDataSource.h"
#import "FLYFeedDelegate.h"
#import "FLYSingleGroupViewController.h"
#import "FLYInlineReplyView.h"
#import "FLYTopicDetailViewController.h"
#import "FLYBarButtonItem.h"
#import "FLYGroupViewController.h"
#import "FLYDownloadManager.h"
#import "FLYPost.h"
#import "SVPullToRefresh.h"
#import "FLYAudioStateManager.h"
#import "FLYPlayableItem.h"
#import "UIColor+FLYAddition.h"

static NSInteger globalPageNum = 1;

@interface FLYFeedViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, FLYFeedTopicTableViewCellDelegate>

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) FLYInlineReplyView *inlineReplyView;
@property (nonatomic) UITableView *feedTableView;
@property (nonatomic) FLYNavigationBarMyGroupButton *customizedTitleView;

@property (nonatomic) FLYFeedDataSource *feedDataSource;
@property (nonatomic) FLYFeedDelegate *feedDelegate;

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) BOOL didSetConstraints;
@property (nonatomic) enum RequestType requestType;

@end

@implementation FLYFeedViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplete:) name:kDownloadCompleteNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _posts = [NSMutableArray new];
    
    self.view.backgroundColor = [UIColor flyBackgroundColorBlue];
    if (![self isKindOfClass:[FLYGroupViewController class]]) {
        [self _loadLeftBarItem];
    }
    [self _addInlineReplyBar];
    
    _feedTableView = [UITableView new];
    _feedTableView.backgroundColor = [UIColor clearColor];
    _feedTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _feedDataSource = [[FLYFeedDataSource alloc] initWithPosts:_posts];
    _feedTableView.dataSource = self;
    _feedTableView.delegate = self;
    [_feedTableView registerClass:[FLYFeedTopicTableViewCell class] forCellReuseIdentifier:@"feedPostCellIdentifier"];
    [self.view addSubview:_feedTableView];
    
    _feedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _feedTableView.scrollsToTop = YES;
    
    _backgroundView = [UIView new];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundView];
    
    __weak typeof(self) weakSelf = self;
//    [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(_addDataSource) userInfo:nil repeats:NO];
    
//    [self performSelector:@selector(_addDataSource) withObject:nil afterDelay:1.0];
    
    [_feedTableView addPullToRefreshWithActionHandler:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.requestType = RequestTypeNormal;
        [strongSelf performSelector:@selector(_addDataSource:) withObject:@(1) afterDelay:1.0];
    }];
    
    // setup infinite scrolling
    __weak typeof(self) weakSelfLoadMore = self;
    [_feedTableView addInfiniteScrollingWithActionHandler:^{
        __strong typeof(self) strongSelf = weakSelfLoadMore;
        strongSelf.requestType = RequestTypeLoadMore;
        [strongSelf performSelector:@selector(_addDataSource:) withObject:@(globalPageNum) afterDelay:1.0];
    }];

    [_feedTableView triggerPullToRefresh];
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
    FLYGroupsButtonItem *leftBarItem = [FLYGroupsButtonItem barButtonItem:YES];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
//    [leftButton addTarget:self action:@selector(_filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    [leftButton sizeToFit];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

- (void)loadRightBarButton
{
    FLYCatalogBarButtonItem *barItem = [FLYCatalogBarButtonItem barButtonItem:NO];
    __weak typeof(self)weakSelf = self;
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        __strong typeof(self) strongSelf = weakSelf;
    };
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewConstraints];
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

//- (UINavigationItem *)navigationItem
//{
//    if (!_customizedTitleView) {
//        _customizedTitleView = [[FLYNavigationBarMyGroupButton alloc] initWithFrame:CGRectMake(0, 0, 120, 32) Title:@"My Groups" icon:@"icon_down_arrow"];
//        
//        [_customizedTitleView addTarget:self action:@selector(_filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//        [_customizedTitleView sizeToFit];
//        [self.navigationItem setTitleView:_customizedTitleView];
//    }
//    return [super navigationItem];
//}

- (void)_addDataSource:(id)argument
{
    globalPageNum = [argument integerValue];
    if (globalPageNum == 1) {
        [_posts removeAllObjects];
    }
    [self _addDatasource:globalPageNum];
    [_feedTableView.pullToRefreshView stopAnimating];
    [_feedTableView.infiniteScrollingView stopAnimating];
}

- (void)_addDatasource:(NSInteger)pageNum
{
    globalPageNum++;
    
    NSInteger postsPerPage = 10;
    NSInteger start = (pageNum - 1) * postsPerPage + 1;
    NSInteger end = start + postsPerPage;
    for (NSInteger i = start; i <= end; i++) {
        FLYPost *post = [[FLYPost alloc] initWithDictory:@{@"count":@(i), @"title":@"Tellm me something I need to know."}];
        [_posts addObject:post];
    }
    [self.feedTableView reloadData];
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

- (FLYFeedTopicTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"feedPostCellIdentifier";
    FLYFeedTopicTableViewCell *cell = (FLYFeedTopicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYFeedTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    cell.backgroundColor = [UIColor clearColor];
    
    //set cell state
    [cell updatePlayState:FLYPlayStateNotSet];
    if ([[FLYAudioStateManager sharedInstance].currentPlayItem.indexPath isEqual:indexPath]) {
        FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *)[FLYAudioStateManager sharedInstance].currentPlayItem.item;
        [cell updatePlayState:[FLYAudioStateManager sharedInstance].currentPlayItem.playState];
    }
    
    cell.post = _posts[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.view layoutIfNeeded];
    FLYTopicDetailViewController *viewController = [FLYTopicDetailViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)downloadComplete:(NSNotification *)notificaiton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *localPath = [notificaiton.userInfo objectForKey:@"localPath"];
        [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
        FLYFeedTopicTableViewCell *currentCell = (FLYFeedTopicTableViewCell *)[FLYAudioStateManager sharedInstance].currentPlayItem.item;
        [currentCell updatePlayState:FLYPlayStatePlaying];
        
        [[FLYAudioStateManager sharedInstance] playAudioURLStr:localPath withCompletionBlock:^{
            [self clearCurrentPlayingItem];
            //If auto play is enabled, play next audio file
            BOOL isAutoPlayEnabled = [FLYAppStateManager sharedInstance].isAutoPlayEnabled;
            if (isAutoPlayEnabled) {
                NSIndexPath *preIndexPath = [FLYAudioStateManager sharedInstance].previousPlayItem.indexPath;
                NSInteger toPlayRow = preIndexPath.row + 1;
                if (toPlayRow >= [self.posts count]) {
                    return;
                }
                FLYPost *postToPlay = self.posts[toPlayRow];
                NSIndexPath *indexPathToPlay = [NSIndexPath indexPathForRow:toPlayRow inSection:preIndexPath.section];
                FLYFeedTopicTableViewCell *toPlayCell = (FLYFeedTopicTableViewCell *)[self.feedTableView cellForRowAtIndexPath:indexPathToPlay];
                [self playButtonTapped:toPlayCell withPost:postToPlay withIndexPath:indexPathToPlay];
            }
        }];
    });
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

- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)tappedCell withPost:(FLYPost *)post withIndexPath:(NSIndexPath *)indexPath
{
    //If currentPlayItem is empty, set the tappedCell as currentPlayItem
    NSIndexPath *tappedCellIndexPath;
    if (!indexPath) {
        tappedCellIndexPath = [self.feedTableView indexPathForCell:tappedCell];
    } else {
        tappedCellIndexPath = indexPath;
    }
    if (![FLYAudioStateManager sharedInstance].currentPlayItem) {
        [FLYAudioStateManager sharedInstance].currentPlayItem = [[FLYPlayableItem alloc] initWithItem:tappedCell playableItemType:FLYPlayableFeed playState:FLYPlayStateNotSet indexPath:tappedCellIndexPath];
    }
    
    //tap on the same cell
    if ([FLYAudioStateManager sharedInstance].currentPlayItem.indexPath == tappedCellIndexPath) {
        if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStateNotSet) {
            [FLYAudioStateManager sharedInstance].currentPlayItem.playState = FLYPlayStateLoading;
            [tappedCell updatePlayState:FLYPlayStateLoading];
            [[FLYDownloadManager sharedInstance] loadAudioByURLString:post.audioURLStr];
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStateLoading) {
            return;
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStatePlaying) {
            [tappedCell updatePlayState:FLYPlayStatePaused];
            [[FLYAudioStateManager sharedInstance] pausePlayer];
        } else if ([FLYAudioStateManager sharedInstance].currentPlayItem.playState == FLYPlayStatePaused) {
            [[FLYAudioStateManager sharedInstance] resumePlayer];
            [tappedCell updatePlayState:FLYPlayStatePlaying];
        }  else {
            [[FLYAudioStateManager sharedInstance] removePlayer];
            [tappedCell updatePlayState:FLYPlayStateFinished];
        }
        
        [FLYAudioStateManager sharedInstance].currentPlayItem.item = tappedCell;
    } else {
        //tap on a different cell
        [[FLYAudioStateManager sharedInstance] removePlayer];
        [[FLYDownloadManager sharedInstance] loadAudioByURLString:post.audioURLStr];
        
        //change previous state, remove animation, change current to previous
        [FLYAudioStateManager sharedInstance].previousPlayItem = [FLYAudioStateManager sharedInstance].currentPlayItem;
        [FLYAudioStateManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
        FLYFeedTopicTableViewCell *previousCell = (FLYFeedTopicTableViewCell *)[FLYAudioStateManager sharedInstance].previousPlayItem.item;
        [previousCell updatePlayState:FLYPlayStateNotSet];
        
    
        [FLYAudioStateManager sharedInstance].currentPlayItem =  [[FLYPlayableItem alloc] initWithItem:tappedCell playableItemType:FLYPlayableFeed playState:FLYPlayStateLoading indexPath:tappedCellIndexPath];
        [tappedCell updatePlayState:FLYPlayStateLoading];
    }
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

@end
