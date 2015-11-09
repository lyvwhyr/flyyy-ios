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

#define kProfileStatInfoTopMargin 90
#define kProfileStatInfoHeight 55
#define kProfileStatInfoWidth 70
#define kProfileStatInfoMiddleSpacing 67
#define kProfileBioTextTopMargin 46

@interface FLYProfileViewController () <YYTextViewDelegate>

@property (nonatomic) UIImageView *bgImageView;
@property (nonatomic) FLYProfileStatInfoView *followerStatView;
@property (nonatomic) FLYProfileStatInfoView *followingStatView;
@property (nonatomic) FLYProfileStatInfoView *postsStatView;
@property (nonatomic) YYTextView *bioTextView;
@property (nonatomic) UIButton *followButton;

@end

@implementation FLYProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.title = @"Me";
    self.bgImageView = [UIImageView new];
    self.bgImageView.image = [UIImage imageNamed:@"profile_bg"];
    [self.view addSubview:self.bgImageView];
    
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
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    CGFloat leftMargin = (CGRectGetWidth([UIScreen mainScreen].bounds) - kProfileStatInfoWidth * 3 - kProfileStatInfoMiddleSpacing * 2) / 2.0f;
    
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
