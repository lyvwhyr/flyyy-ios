//
//  FLYMyRepliesViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 4/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYMyRepliesViewController.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"
#import "UIColor+FLYAddition.h"
#import "FLYReplyService.h"
#import "SVPullToRefresh.h"
#import "FLYReply.h"
#import "FLYTopic.h"
#import "FLYMyRepliesCell.h"
#import "FLYTopicDetailViewController.h"
#import "FLYAudioItem.h"
#import "FLYAudioManager.h"

@interface FLYMyRepliesViewController ()<UITableViewDataSource, UITableViewDelegate, FLYMyRepliesCellDelegate>

@property (nonatomic) UITableView *repliesTableView;

@property (nonatomic) NSMutableArray *entries;

// used for reply pagination
@property (nonatomic) NSString *beforeTimestamp;

// services
@property (nonatomic) FLYReplyService *replyService;

@end

@implementation FLYMyRepliesViewController

- (instancetype)init
{
    if (self = [super init]) {
        _entries = [NSMutableArray new];
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LOC(@"FLYEverythingElseMyReplies");
    
    self.repliesTableView = [UITableView new];
    self.repliesTableView.delegate = self;
    self.repliesTableView.dataSource = self;
    self.repliesTableView.scrollsToTop = YES;
    self.repliesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.repliesTableView];
    
    [self _addViewConstraints];
    
    [self _initService];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self _clearAllPlaying];
}

- (void)_addViewConstraints
{
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight;
    [self.repliesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(tableViewHeight));
    }];
}


#pragma mark - UITableViewDelegate, datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"FLYMyRepliesCellIdentifier", (int)indexPath.section, (int)indexPath.row];
    FLYMyRepliesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYMyRepliesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLYTopic *topic = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"topic"];
    FLYReply *reply = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"reply"];
    cell.indexPath = indexPath;
    [cell setupCellWithTopic:topic reply:reply];
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FLYTopic *topic = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"topic"];
    FLYTopicDetailViewController *viewController = [[FLYTopicDetailViewController alloc] initWithTopic:topic];
    viewController.isBackFullScreen = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // stop previous. same cell.
    if (![[FLYAudioManager sharedInstance].previousPlayItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem] && [FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemMyRepliesReply && indexPath == [FLYAudioManager sharedInstance].previousPlayItem.indexPath) {
        [self _clearPreviousPlayingItem];
    }
    
    if (indexPath != [FLYAudioManager sharedInstance].currentPlayItem.indexPath) {
        FLYMyRepliesCell *displayedCell = (FLYMyRepliesCell *)cell;
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


#pragma mark - services
- (void)_initService
{
    @weakify(self)
    [self.repliesTableView addPullToRefreshWithActionHandler:^{
        @strongify(self)
        [self _load:YES before:nil];
    }];
    
    
    [self.repliesTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO before:self.beforeTimestamp];
    }];
    
    [self _load:YES before:nil];
}

- (void)_load:(BOOL)first before:(NSString *)before
{
    if (!self.replyService) {
        self.replyService = [FLYReplyService getMyReplies];
    }
    
    self.state = FLYViewControllerStateLoading;
    @weakify(self)
    FLYGetMyRepliesSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.repliesTableView.pullToRefreshView stopAnimating];
        [self.repliesTableView.infiniteScrollingView stopAnimating];

        NSArray *repliesArray = responseObj;
        if (repliesArray || [repliesArray count] == 0) {
            self.state = FLYViewControllerStateError;
        }
        
        self.state = FLYViewControllerStateReady;
        if (first) {
            [self.entries removeAllObjects];
        }
        
        for(int i = 0; i < repliesArray.count; i++) {
            FLYReply *reply = [[FLYReply alloc] initWithDictionary:repliesArray[i]];
            FLYTopic *topic = [[FLYTopic alloc] initWithDictory:[repliesArray[i] objectForKey:@"topic"]];
            // If topic is empty, it means the topic has been removed. The reply shouldn't be displayed in this case.
            if (!topic.topicId) {
                continue;
            }
            NSDictionary *dict = @{@"topic":topic, @"reply":reply};
            [self.entries addObject:dict];
        }
        //Set up before id for load more
        NSDictionary *lastEntry = [self.entries lastObject];
        self.beforeTimestamp = ((FLYReply *)[lastEntry objectForKey:@"reply"]).createdAt;
        [self.repliesTableView reloadData];
    };
    FLYGetMyRepliesErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        [self.repliesTableView.pullToRefreshView stopAnimating];
        [self.repliesTableView.infiniteScrollingView stopAnimating];
    };
    [self.replyService nextPage:before firstPage:first successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark - FLYMyRepliesCellDelegate

- (void)playButtonTapped:(FLYMyRepliesCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    // clear the reset of the cells
    NSArray *visibleCells = [self.repliesTableView visibleCells];
    for (int i = 0; i < visibleCells.count; i++) {
        FLYMyRepliesCell *visibleCell = (FLYMyRepliesCell *)(visibleCells[i]);
        if (visibleCell.indexPath != cell.indexPath) {
            [visibleCell updatePlayState:FLYPlayStateNotSet];
        }
    }
    
    FLYReply *reply = cell.reply;
    FLYAudioItem *newItem = [[FLYAudioItem alloc] initWithUrl:[NSURL URLWithString:reply.mediaURL] andCount:0 indexPath:indexPath itemType:FLYPlayableItemMyRepliesReply playState:FLYPlayStateNotSet audioDuration:reply.audioDuration];
    
    if ([newItem isEqual:[FLYAudioManager sharedInstance].currentPlayItem]) {
        newItem = [FLYAudioManager sharedInstance].currentPlayItem;
    }
    
    [[FLYAudioManager sharedInstance] updateAudioState:newItem];
}


#pragma mark - Audio related methods
- (void)_clearAllPlaying
{
    if ([FLYAudioManager sharedInstance].previousPlayItem) {
        FLYMyRepliesCell *previousPlayingCell = (FLYMyRepliesCell *)([self.repliesTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
        [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
        [FLYAudioManager sharedInstance].previousPlayItem = nil;
    }
    
    if ([FLYAudioManager sharedInstance].currentPlayItem) {
        FLYMyRepliesCell *currentCell = (FLYMyRepliesCell *)([self.repliesTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
        [currentCell updatePlayState:FLYPlayStateNotSet];
        [FLYAudioManager sharedInstance].currentPlayItem = nil;
    }
    [[FLYAudioManager sharedInstance].audioPlayer stop];
}

- (void)_clearPreviousPlayingItem
{
    if (![FLYAudioManager sharedInstance].previousPlayItem) {
        return;
    }
    
    FLYMyRepliesCell *previousPlayingCell = (FLYMyRepliesCell *)([self.repliesTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].previousPlayItem.indexPath]);
    [FLYAudioManager sharedInstance].previousPlayItem.playState = FLYPlayStateNotSet;
    [previousPlayingCell updatePlayState:FLYPlayStateNotSet];
}

- (void)_downloadComplete:(NSNotification *)notificaiton
{
    NSString *localPath = [notificaiton.userInfo objectForKey:kDownloadAudioLocalPathkey];
    if([FLYAudioManager sharedInstance].currentPlayItem.itemType != FLYPlayableItemMyRepliesReply) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
        NSURL* url = [NSURL fileURLWithPath:localPath];
        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
        [[FLYAudioManager sharedInstance].audioPlayer setDataSource:dataSource withQueueItemId:[FLYAudioManager sharedInstance].currentPlayItem];
    });
}

- (void)_audioPlayStateChanged:(NSNotification *)notif
{
    FLYAudioItem *currentItem = [FLYAudioManager sharedInstance].currentPlayItem;
    if (currentItem.itemType != FLYPlayableItemMyRepliesReply) {
        return;
    }
    
    FLYMyRepliesCell *currentCell = (FLYMyRepliesCell *) [self.repliesTableView cellForRowAtIndexPath:currentItem.indexPath];
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
        if([FLYAudioManager sharedInstance].currentPlayItem && [FLYAudioManager sharedInstance].currentPlayItem.itemType == FLYPlayableItemMyRepliesReply && [FLYAudioManager sharedInstance].currentPlayItem.indexPath == queueItemId.indexPath) {
            FLYMyRepliesCell *currentCell = (FLYMyRepliesCell *)([self.repliesTableView cellForRowAtIndexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath]);
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateNotSet;
            [currentCell updatePlayState:FLYPlayStateNotSet];
        }
    }
    
    // stop previous
    if ([FLYAudioManager sharedInstance].previousPlayItem && [FLYAudioManager sharedInstance].previousPlayItem.itemType == FLYPlayableItemMyRepliesReply) {
        [self _clearPreviousPlayingItem];
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

@end
