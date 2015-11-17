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
#import "FLYUsersService.h"
#import "FLYUser.h"
#import "FLYFollowingUserListViewController.h"

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

@property (nonatomic) NSString *userId;
@property (nonatomic) FLYUser *user;

@property (nonatomic) FLYMyTopicsViewController *myPostViewController;

// service
@property (nonatomic) FLYUsersService *usersService;

@end

@implementation FLYProfileViewController

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init]) {
        _userId = userId;
        FLYUser *currentUser = [FLYAppStateManager sharedInstance].currentUser;
        if (!currentUser) {
            _isSelf = NO;
        } else {
            if ([currentUser isEqual:userId]) {
                _isSelf = YES;
            } else {
                _isSelf = NO;
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.topBgView = [UIView new];
    self.topBgView.backgroundColor = [UIColor flyBlue];
    [self.view addSubview:self.topBgView];
    
    // followers, following, andposts info
    self.followerStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"followers"];
    [self.view addSubview:self.followerStatView];
    
    self.followingStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"following"];
    UITapGestureRecognizer *followingTapGestureRecognizer = [UITapGestureRecognizer new];
    [followingTapGestureRecognizer addTarget:self action:@selector(_followingViewTapped)];
    [self.followingStatView addGestureRecognizer:followingTapGestureRecognizer];
    [self.view addSubview:self.followingStatView];
    
    self.postsStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"posts"];
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
    [self.followButton addTarget:self action:@selector(_followUser) forControlEvents:UIControlEventTouchUpInside];
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
    
    if (self.isSelf) {
        self.user = [FLYAppStateManager sharedInstance].currentUser;
        [self _updateProfileByUser:self.user];
    } else {
        [self _initService];
    }
}

- (void)_initService
{
    FLYGetUserByUserIdSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj)
    {
        if (responseObj) {
            self.user = [[FLYUser alloc] initWithDictionary:responseObj];
            [self _updateProfileByUser:self.user];
        }
    };
    
    FLYGetUserByUserIdErrorBlock errorBlock = ^(id responseObj, NSError *error)
    {
        
    };
    
    [FLYUsersService getUserWithUserId:self.userId successBlock:successBlock error:errorBlock];
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

- (void)_followUser
{
    [FLYUsersService followUserByUserId:self.userId isFollow:YES successBlock:nil error:nil];
}

- (void)_followingViewTapped
{
    FLYFollowingUserListViewController *vc = [FLYFollowingUserListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - update profile
- (void)_updateProfileByUser:(FLYUser *)user
{
    self.title = [NSString stringWithFormat:@"@%@", user.userName];
    
    // update profile stat
    [self.followerStatView setCount:user.followerCount];
    [self.followingStatView setCount:user.followeeCount];
    [self.postsStatView setCount:user.topicCount];
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
