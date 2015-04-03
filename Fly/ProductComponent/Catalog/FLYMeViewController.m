//
//  FLYEverythingElseViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYMeViewController.h"
#import "FLYEverythingElseCell.h"
#import "FLYSettingsViewController.h"
#import "FLYNavigationController.h"
#import "FLYFeedViewController.h"
#import "FLYBarButtonItem.h"
#import "UIColor+FLYAddition.h"
#import "FLYSettingsViewController.h"

#define kNumberOfItems 3

@interface FLYMeViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UITableView *tableView;

@end

@implementation FLYMeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.flyNavigationController.interactivePopGestureRecognizer addTarget:self
                                                                     action:@selector(interactivePopGesture:)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.flyNavigationController.interactivePopGestureRecognizer removeTarget:self action:nil];
    
}

- (void)dealloc
{
    
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

#pragma mark - UITableViewDelegate

- (FLYEverythingElseCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYEverythingElseCell";
    FLYEverythingElseCell *cell = [[FLYEverythingElseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    switch (indexPath.row) {
        case FLYEverythingElseCellTypePosts: {
            [cell configCellWithImage:@"icon_everything_else_my_posts" text:LOC(@"FLYEverythingElseMyPosts")];
            break;
        }
        case FLYEverythingElseCellTypeReplies: {
            [cell configCellWithImage:@"icon_everything_else_my_replies" text:LOC(@"FLYEverythingElseMyReplies")];
            break;
        }
        case FLYEverythingElseCellTypeSettings: {
            [cell configCellWithImage:@"icon_everything_else_settings" text:LOC(@"FLYEverythingElseSettings")];
            break;
        }
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 44 - segmented control height
    return (CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarHeight - kNavBarHeight)/kNumberOfItems;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case FLYEverythingElseCellTypePosts: {
            break;
        }
        case FLYEverythingElseCellTypeReplies: {
            break;
        }
        case FLYEverythingElseCellTypeSettings: {
            FLYSettingsViewController *vc = [FLYSettingsViewController new];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfItems;
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

- (void)_addViewConstraints
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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

- (void)_backButtonTapped
{
    self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    [self.view layoutIfNeeded];
    [self.flyNavigationController popViewControllerAnimated:YES];
}

- (void)interactivePopGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
        [self.view layoutIfNeeded];
        [self.flyNavigationController popViewControllerAnimated:YES];
    }
}

@end
