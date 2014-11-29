//
//  FLYFeedViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedViewController.h"
#import "FLYFeedTopicTableViewCell.h"

@interface FLYFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *feedTableView;

@property (nonatomic) NSMutableArray *posts;

@end

@implementation FLYFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _posts = [NSMutableArray new];
    [self _addDatasource];
    
    _feedTableView = [UITableView new];
    _feedTableView.delegate = self;
    _feedTableView.dataSource = self;
    [self.view addSubview:_feedTableView];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewConstraints];
}

#pragma mark - UITableViewDelegate, datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}



- (void)updateViewConstraints
{
    [self.view removeConstraints:[self.view constraints]];
    
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.parentViewController.view);
        make.leading.equalTo(self.parentViewController.view);
        make.width.equalTo(@(CGRectGetWidth(self.parentViewController.view.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.view.superview.bounds) - kTabBarViewHeight));
    }];

    [_feedTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
}

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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [FLYUtilities printAutolayoutTrace];
}

@end
