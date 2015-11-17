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

@interface FLYFollowingUserListViewController ()

@property (nonatomic) FLYFollowUserTableView *followingUserTable;

@end

@implementation FLYFollowingUserListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Following";
    
    self.followingUserTable = [[FLYFollowUserTableView alloc] initWithType:FLYFollowTypeFollowing];
    self.followingUserTable.backgroundColor = [UIColor blueColor];
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
