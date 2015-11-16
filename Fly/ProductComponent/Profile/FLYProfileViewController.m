//
//  FLYProfileViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYProfileViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYProfileStatInfoView.h"
#import "YYText.h"
#import "UIFont+FLYAddition.h"
#import "UIView+FLYAddition.h"
#import "FLYMyTopicsViewController.h"
#import "FLYNavigationController.h"
#import "FLYBadgeView.h"

#define kTopBackgroundHeight 320
#define kProfileStatInfoTopMargin 80
#define kProfileStatInfoHeight 55
#define kProfileStatInfoWidth 70
#define kProfileStatInfoMiddleSpacing 67
#define kProfileBioTextTopMargin 26
#define kProfileBadgeSize 90

@interface FLYProfileViewController () <YYTextViewDelegate>

@property (nonatomic) UIView *topBgView;
@property (nonatomic) UIImageView *triangleBgImageView;
@property (nonatomic) FLYProfileStatInfoView *followerStatView;
@property (nonatomic) FLYProfileStatInfoView *followingStatView;
@property (nonatomic) FLYProfileStatInfoView *postsStatView;
@property (nonatomic) YYTextView *bioTextView;
@property (nonatomic) UIButton *followButton;
@property (nonatomic) FLYBadgeView *badgeView;

@property (nonatomic) FLYMyTopicsViewController *myPostViewController;

@end

@implementation FLYProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.title = @"Me";
    self.topBgView = [UIView new];
    self.topBgView.backgroundColor = [UIColor flyBlue];
    [self.view addSubview:self.topBgView];
    
    // followers, following, andposts info
    self.followerStatView = [[FLYProfileStatInfoView alloc] initWithCount:1 name:@"followers"];
    [self.view addSubview:self.followerStatView];
    
    self.followingStatView = [[FLYProfileStatInfoView alloc] initWithCount:1 name:@"following"];
    [self.view addSubview:self.followingStatView];
    
    self.postsStatView = [[FLYProfileStatInfoView alloc] initWithCount:1 name:@"posts"];
    [self.view addSubview:self.postsStatView];
    
    self.bioTextView = [YYTextView new];
    self.bioTextView.text = @"\"Tell us about yourself\"";
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.font = [UIFont flyFontWithSize:19];
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
//    self.bioTextView.size = CGSizeMake(CGRectGetWidth(self.view.bounds) - 2 * kProfileStatInfoWidth, 52);
    [self.view addSubview:self.bioTextView];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followButton setImage:[UIImage imageNamed:@"icon_follow_user"] forState:UIControlStateNormal];
    [self.followButton sizeToFit];
    [self.view addSubview:self.followButton];
    
    self.myPostViewController = [[FLYMyTopicsViewController alloc] init];
    [self addChildViewController:self.myPostViewController];
    [self.view insertSubview:self.myPostViewController.view belowSubview:self.topBgView];
    
    
    self.triangleBgImageView = [UIImageView new];
    self.triangleBgImageView.image = [UIImage imageNamed:@"icon_triangle_profile_bg"];
    [self.triangleBgImageView sizeToFit];
    [self.view addSubview:self.triangleBgImageView];
    
    self.badgeView = [[FLYBadgeView alloc] initWithPoint:10];
    [self.view addSubview:self.badgeView];
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 44);
//    
//       self.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 44);
}

- (void)updateViewConstraints
{
    CGFloat leftMargin = (CGRectGetWidth([UIScreen mainScreen].bounds) - kProfileStatInfoWidth * 3 - kProfileStatInfoMiddleSpacing * 2) / 2.0f;
    
    
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(kTopBackgroundHeight));
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
    
    [self.followerStatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kProfileStatInfoTopMargin);
        make.leading.equalTo(self.view).offset(leftMargin);
        make.width.equalTo(@(kProfileStatInfoWidth));
        make.height.equalTo(@(kProfileStatInfoHeight));
    }];
    
    [self.followingStatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.followerStatView);
        make.leading.equalTo(self.followerStatView.mas_trailing).offset(kProfileStatInfoMiddleSpacing);
        make.width.equalTo(@(kProfileStatInfoWidth));
        make.height.equalTo(@(kProfileStatInfoHeight));
    }];
    
    [self.postsStatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.followerStatView);
        make.leading.equalTo(self.followingStatView.mas_trailing).offset(kProfileStatInfoMiddleSpacing);
        make.width.equalTo(@(kProfileStatInfoWidth));
        make.height.equalTo(@(kProfileStatInfoHeight));
    }];
    
    [self.bioTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.followerStatView.mas_bottom).offset(kProfileBioTextTopMargin);
        make.leading.equalTo(self.followerStatView);
        make.trailing.equalTo(self.postsStatView);
        make.height.equalTo(@(52));
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bioTextView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    [self.triangleBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgView.mas_bottom).offset(-1);
    }];
    
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.triangleBgImageView).offset(-10);
        make.trailing.equalTo(self.view).offset(-58);
        make.width.equalTo(@(kProfileBadgeSize));
        make.height.equalTo(@(kProfileBadgeSize));
    }];
    
    [self.myPostViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.triangleBgImageView).offset(-44-44-44);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
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
