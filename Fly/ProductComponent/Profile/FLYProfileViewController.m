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
#import "FLYShareManager.h"
#import "Dialog.h"
#import "FLYFollowerListViewController.h"

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
            if ([currentUser.userId isEqual:userId]) {
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
    
    // observers need to be called on every viewController creation. Otherwise, profile view won't be updated correctly
    [self _addObservers];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.topBgView = [UIView new];
    self.topBgView.backgroundColor = [UIColor flyBlue];
    [self.view addSubview:self.topBgView];
    
    // followers, following, andposts info
    self.followerStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"followers"];
    UITapGestureRecognizer *followerTapGestureRecognizer = [UITapGestureRecognizer new];
    [followerTapGestureRecognizer addTarget:self action:@selector(_followerViewTapped)];
    [self.followerStatView addGestureRecognizer:followerTapGestureRecognizer];
    [self.view addSubview:self.followerStatView];
    
    self.followingStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"following"];
    UITapGestureRecognizer *followingTapGestureRecognizer = [UITapGestureRecognizer new];
    [followingTapGestureRecognizer addTarget:self action:@selector(_followingViewTapped)];
    [self.followingStatView addGestureRecognizer:followingTapGestureRecognizer];
    [self.view addSubview:self.followingStatView];
    
    self.postsStatView = [[FLYProfileStatInfoView alloc] initWithCount:0 name:@"posts"];
    UITapGestureRecognizer *postsTapGestureRecognizer = [UITapGestureRecognizer new];
    [postsTapGestureRecognizer addTarget:self action:@selector(_postsViewTapped)];
    [self.postsStatView addGestureRecognizer:postsTapGestureRecognizer];
    [self.view addSubview:self.postsStatView];
    
    self.bioTextView = [YYTextView new];
    self.bioTextView.text = @"\"Tell us about yourself\"";
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.font = [UIFont flyFontWithSize:19];
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.bioTextView];
    
    self.myPostViewController = [[FLYMyTopicsViewController alloc] init];
    self.myPostViewController.isFullScreen = NO;
    [self addChildViewController:self.myPostViewController];
    [self.view insertSubview:self.myPostViewController.view belowSubview:self.topBgView];
    
    
    self.triangleBgImageView = [UIImageView new];
    self.triangleBgImageView.image = [UIImage imageNamed:@"icon_triangle_profile_bg"];
    [self.triangleBgImageView sizeToFit];
    [self.view insertSubview:self.triangleBgImageView belowSubview:self.topBgView];
    
    self.badgeView = [[FLYBadgeView alloc] initWithPoint:10];
    [self.view addSubview:self.badgeView];
    
    [self updateViewConstraints];
    
    if (self.isSelf) {
        [self _initOrUpdateFollowView];
        self.user = [FLYAppStateManager sharedInstance].currentUser;
        [self _updateProfileByUser];
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
            [self _updateProfileByUser];
        }
    };
    
    FLYGetUserByUserIdErrorBlock errorBlock = ^(id responseObj, NSError *error)
    {
        
    };
    
    [FLYUsersService getUserWithUserId:self.userId successBlock:successBlock error:errorBlock];
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_followUpdated:) name:kNotificationFollowUserChanged object:nil];
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
        make.leading.equalTo(self.view).offset(-3);
        make.trailing.equalTo(self.view).offset(3);
        make.top.equalTo(self.topBgView.mas_bottom).offset(-3);
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

- (void)_followButtonTapped
{
    if (self.isSelf) {
        [FLYShareManager shareProfile:self profileName:self.user.userName];
    } else {
        if (self.user) {
            [self.user followUser];
        } else {
            UALog(@"user to follow is nil");
        }
    }
}

- (void)_followingViewTapped
{
    FLYFollowingUserListViewController *vc = [[FLYFollowingUserListViewController alloc] initWithUserId:self.user.userId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_followerViewTapped
{
    FLYFollowerListViewController *vc = [[FLYFollowerListViewController alloc] initWithUserId:self.user.userId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_postsViewTapped
{
    if (self.isSelf) {
        FLYMyTopicsViewController *vc = [FLYMyTopicsViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [Dialog simpleToast:LOC(@"FLYProfilePostsLocked")];
    }
}

#pragma mark - update profile
- (void)_updateProfileByUser
{
    self.title = [NSString stringWithFormat:@"@%@", self.user.userName];
    
    // update profile stat
    [self _updateFollowerStatView];
    [self _updateFollowingStatView];
    [self.postsStatView setCount:self.user.topicCount];
    [self _initOrUpdateFollowView];
    
    [self updateViewConstraints];
}

- (void)_initOrUpdateFollowView
{
    if (!self.followButton) {
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton setImage:[UIImage imageNamed:@"icon_follow_user"] forState:UIControlStateNormal];
        [self.followButton addTarget:self action:@selector(_followButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.followButton sizeToFit];
        [self.view addSubview:self.followButton];
    }
    
    if (self.isSelf) {
        [self.followButton setImage:[UIImage imageNamed:@"icon_share_user"] forState:UIControlStateNormal];
    } else {
        if (self.user.isFollowing) {
            [self.followButton setImage:[UIImage imageNamed:@"icon_unfollow_user"] forState:UIControlStateNormal];
        } else {
            [self.followButton setImage:[UIImage imageNamed:@"icon_follow_user"] forState:UIControlStateNormal];
        }
    }
}

- (void)_updateFollowerStatView
{
    [self.followerStatView setCount:self.user.followerCount];
}

- (void)_updateFollowingStatView
{
    [self.followingStatView setCount:self.user.followingCount];
}


#pragma mark - Follow notification

- (void)_followUpdated:(NSNotification *)notification
{
    // user is currenlty viewing page
    // self.user used to render profile page
    FLYUser *user = [notification.userInfo objectForKey:@"user"];
    FLYUser *currentUser = [FLYAppStateManager sharedInstance].currentUser;
    // update viewing page
    if ([user.userId isEqualToString:self.user.userId]) {
        if (self.user.isFollowing) {
            self.user.followerCount++;
        } else {
            if (self.user.followerCount > 0) {
                self.user.followerCount--;
            }
        }
        [self _updateFollowerStatView];
        
        // update my profile page
    } else if ([self.user.userId isEqualToString:currentUser.userId]) {
        if (user.isFollowing) {
            self.user.followingCount++;
        } else {
            if (self.user.followingCount > 0) {
                self.user.followingCount--;
            }
        }
        [self _updateFollowingStatView];
    } else {
        return;
    }
    
    self.user.isFollowing = user.isFollowing;
    [self _initOrUpdateFollowView];
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
