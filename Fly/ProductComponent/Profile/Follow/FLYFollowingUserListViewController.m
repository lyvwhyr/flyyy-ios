//
//  FLYFollowingUserListViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 11/16/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFollowingUserListViewController.h"
#import "FLYFollowUserTableView.h"
#import "UIColor+FLYAddition.h"
#import "FLYProfileViewController.h"
#import "FLYUser.h"

@interface FLYFollowingUserListViewController () <FLYFollowUserTableViewDelegate>

@property (nonatomic) FLYFollowUserTableView *followingUserTable;
@property (nonatomic) NSString *userId;

@end

@implementation FLYFollowingUserListViewController

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init]) {
        _userId = userId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Following";
    
    self.followingUserTable = [[FLYFollowUserTableView alloc] initWithType:FLYFollowTypeFollowing userId:self.userId];
    self.followingUserTable.backgroundColor = [UIColor blueColor];
    self.followingUserTable.delegate = self;
    [self.view addSubview:self.followingUserTable];
    [self _addViewConstraints];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)_addViewConstraints
{
    [self.followingUserTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - FLYFollowUserTableViewDelegate

- (void)tableCellTapped:(FLYFollowUserTableView *)tableView user:(FLYUser *)user
{
    FLYProfileViewController *profileVC = [[FLYProfileViewController alloc] initWithUserId:user.userId];
    [self.navigationController pushViewController:profileVC animated:YES];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
