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

@interface FLYFeedViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, FLYFeedTopicTableViewCellDelegate>

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) FLYInlineReplyView *inlineReplyView;
@property (nonatomic) UITableView *feedTableView;
@property (nonatomic) FLYNavigationBarMyGroupButton *customizedTitleView;

@property (nonatomic) FLYFeedDataSource *feedDataSource;
@property (nonatomic) FLYFeedDelegate *feedDelegate;

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) BOOL didSetConstraints;

@end

@implementation FLYFeedViewController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _posts = [NSMutableArray new];
    
    if (![self isKindOfClass:[FLYGroupViewController class]]) {
        [self _loadLeftBarItem];
    }
    [self _addInlineReplyBar];
    [self _addDatasource];
    
    _feedTableView = [UITableView new];
    _feedTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _feedDataSource = [[FLYFeedDataSource alloc] initWithPosts:_posts];
    _feedTableView.dataSource = self;
    _feedTableView.delegate = self;
    [_feedTableView registerClass:[FLYFeedTopicTableViewCell class] forCellReuseIdentifier:@"feedPostCellIdentifier"];
    [self.view addSubview:_feedTableView];
    
    _feedTableView.scrollsToTop = YES;
    
    _backgroundView = [UIView new];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundView];
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
    FLYNavigationBarMyGroupButton *leftButton = [[FLYNavigationBarMyGroupButton alloc] initWithFrame:CGRectMake(0, 0, 120, 32) Title:@"My Feed" icon:@"icon_down_arrow"];
    
    [leftButton addTarget:self action:@selector(_filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
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

- (void)_addDatasource
{
    /*
     @property (nonatomic, copy) NSString *postAt;
     @property (nonatomic, copy) NSString *audioURL;
     @property (nonatomic) NSInteger likeCount;
     @property (nonatomic) NSInteger replyCount;
     @property (nonatomic) NSInteger audioLength;
     */
    
    NSDictionary *p1 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    NSDictionary *p2 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    NSDictionary *p3 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    NSDictionary *p4 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    NSDictionary *p5 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    NSDictionary *p6 = @{@"title":@"Just broke up with my gf", @"user_name":@"pancake", @"postAt":@"1m", @"audio_url":@"http://freedownloads.last.fm/download/569264057/Get+Got.mp3", @"like_count":@(10), @"reply_count":@(25), @"audio_length":@(48), @"group_name":@"Confession"};
    [_posts addObject:p1];
    [_posts addObject:p2];
    [_posts addObject:p3];
    [_posts addObject:p4];
    [_posts addObject:p5];
    [_posts addObject:p6];
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

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell
{
     self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.view layoutIfNeeded];
    [self.view bringSubviewToFront:_inlineReplyView];
    [self _moveInlineReplyViewOnScreen];
    [self.view needsUpdateConstraints];
    [self.view layoutIfNeeded];
}

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
