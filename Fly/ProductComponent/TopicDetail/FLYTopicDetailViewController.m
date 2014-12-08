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
#import "FLYReplyTableViewCell.h"

@interface FLYTopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *topicTableView;

@property (nonatomic) NSMutableArray *replies;

@end

@implementation FLYTopicDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _replies = [NSMutableArray new];
        [_replies addObject:@"1"];
        [_replies addObject:@"2"];
        [_replies addObject:@"3"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _topicTableView = [UITableView new];
    _topicTableView.delegate = self;
    _topicTableView.dataSource = self;
    [self.view addSubview:_topicTableView];
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_topicTableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [FLYUtilities printAutolayoutTrace];
}

- (void)updateViewConstraints
{
    [_topicTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight));
    }];
    
    [super updateViewConstraints];
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
        static NSString *cellIdentifier = @"flyTopicDetailViewControllerTopicCellIdentifier";
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
    } else {
        static NSString *cellIdentifier = @"flyTopicDetailViewControllerReplyCellIdentifier";
        cell = (FLYReplyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FLYReplyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FlyTopicCellSectionIndex) {
        return 150;
    }
    return 90;
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

- (void)_backButtonTapped
{
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    [self.view layoutIfNeeded];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
