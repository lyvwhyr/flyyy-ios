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
#import "FLYUserFeedViewController.h"
#import "FLYRecordViewController.h"
#import "FLYAudioManager.h"
#import "NAKPlaybackIndicatorView.h"
#import "FLYAudioItem.h"
#import "FLYBarButtonItem.h"
#import "FLYProfileOnboardingView.h"
#import "FLYMainViewController.h"

#define kTopBackgroundHeight 320
#define kProfileAudioBioLeftMargin 20
#define kProfileAudioBioWidth 54
#define kProfileAudioBioTopMargin 80
#define kProfileStatInfoHeight 55
#define kProfileStatInfoWidth 70
#define kProfileStatInfoPostsRightMargin 5
#define kProfileBioTextTopMargin 26
#define kProfileBioTextLeftMargin 20
#define kProfileBadgeSize 90

@interface FLYProfileViewController () <YYTextViewDelegate>

@property (nonatomic) UIView *topBgView;
@property (nonatomic) UIImageView *triangleBgImageView;
@property (nonatomic) FLYProfileStatInfoView *followerStatView;
@property (nonatomic) FLYProfileStatInfoView *followingStatView;
@property (nonatomic) FLYProfileStatInfoView *postsStatView;
@property (nonatomic) YYTextView *bioTextView;

@property (nonatomic) NAKPlaybackIndicatorView *playbackIndicatorView;
@property (nonatomic) UIImageView *audioBioPlaybackBg;

@property (nonatomic) UIButton *followButton;
@property (nonatomic) FLYBadgeView *badgeView;

@property (nonatomic) NSString *userId;
@property (nonatomic) FLYUser *user;

@property (nonatomic) FLYMyTopicsViewController *myPostViewController;
@property (nonatomic) FLYUserFeedViewController *otherUserFeedViewController;

// service
@property (nonatomic) FLYUsersService *usersService;

@property (nonatomic) NSInteger currentNumberOfBioLines;

@property (nonatomic) BOOL shouldAdjustFeedHeight;

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.font = [UIFont flyFontWithSize:19];
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    self.bioTextView.returnKeyType = UIReturnKeyDone;
    self.bioTextView.userInteractionEnabled = NO;
    self.bioTextView.delegate = self;
    [self.view addSubview:self.bioTextView];
    
    self.audioBioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.audioBioButton setImage:[UIImage imageNamed:@"icon_profile_playback"] forState:UIControlStateNormal];
    [self.audioBioButton addTarget:self action:@selector(_audioBioButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.audioBioButton sizeToFit];
    [self.view addSubview:self.audioBioButton];
    
    if (self.isSelf) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL hasSeenOnboarding = [[defaults objectForKey:kProfileAudioBioOnboardingKey] boolValue];
        if (!hasSeenOnboarding) {
            [self _loadProfileOnboarding];
        }
        
        self.bioTextView.userInteractionEnabled = YES;
        self.user = [FLYAppStateManager sharedInstance].currentUser;
        self.myPostViewController = [[FLYMyTopicsViewController alloc] init];
        self.myPostViewController.isFullScreen = NO;
        [self addChildViewController:self.myPostViewController];
        [self.view insertSubview:self.myPostViewController.view belowSubview:self.topBgView];
        [self _updateProfileByUser];
    } else {
        [self _initService];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.shouldAdjustFeedHeight = YES;
}

- (void)_initService
{
    FLYGetUserByUserIdSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj)
    {
        if (responseObj) {
            self.user = [[FLYUser alloc] initWithDictionary:responseObj];
            [self _initOtherFeedView];
            [self _updateProfileByUser];
            
            [self _playAudioBio];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_audioBioUpdated:) name:kNotificationAudioBioUpdated object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_audioBioCompletedPlaying:) name:kNotificationDidFinishPlaying object:nil];
}

- (void)updateViewConstraints
{
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(kTopBackgroundHeight));
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
    
    if (CGRectGetWidth([UIScreen mainScreen].bounds) > 375) {
        [self.audioBioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(40);
            make.top.equalTo(self.view).offset(kProfileAudioBioTopMargin);
        }];
        
        [self.postsStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.followerStatView);
            make.trailing.equalTo(self.view).offset(-30);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followingStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.postsStatView.mas_leading).offset(-25);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followerStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.followingStatView.mas_leading).offset(-25);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
    } else if (CGRectGetWidth([UIScreen mainScreen].bounds) > 320) {
        [self.audioBioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(30);
            make.top.equalTo(self.view).offset(kProfileAudioBioTopMargin);
        }];
        
        [self.postsStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.followerStatView);
            make.trailing.equalTo(self.view).offset(-15);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followingStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.postsStatView.mas_leading).offset(-20);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followerStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.followingStatView.mas_leading).offset(-20);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
    } else {
        CGFloat middleSpacing = (CGRectGetWidth([UIScreen mainScreen].bounds) - kProfileAudioBioWidth - kProfileStatInfoWidth * 3 - kProfileAudioBioLeftMargin *2) / 3.0f;
        
        [self.audioBioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view).offset(kProfileAudioBioLeftMargin);
            make.top.equalTo(self.view).offset(kProfileAudioBioTopMargin);
        }];
        
        [self.postsStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.followerStatView);
            make.trailing.equalTo(self.view).offset(-kProfileStatInfoPostsRightMargin);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followingStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.postsStatView.mas_leading).offset(-middleSpacing);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
        
        [self.followerStatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.audioBioButton);
            make.trailing.equalTo(self.followingStatView.mas_leading).offset(-middleSpacing);
            make.width.equalTo(@(kProfileStatInfoWidth));
            make.height.equalTo(@(kProfileStatInfoHeight));
        }];
    }

    [self.audioBioPlaybackBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.audioBioButton);
    }];
    
    [self.playbackIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.audioBioButton);
        make.width.equalTo(@(kProfileAudioBioWidth));
        make.height.equalTo(@(kProfileAudioBioWidth));
    }];
    
    CGFloat bioTextHeight = [self _getBioTextHeight:self.bioTextView.text];
    
    [self.bioTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.followerStatView.mas_bottom).offset(kProfileBioTextTopMargin);
        make.leading.equalTo(@(kProfileBioTextLeftMargin));
        make.trailing.equalTo(@(-kProfileBioTextLeftMargin));
        make.height.equalTo(@(bioTextHeight));
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
        make.trailing.equalTo(self.view).offset(-48);
        make.width.equalTo(@(kProfileBadgeSize));
        make.height.equalTo(@(kProfileBadgeSize));
    }];
    
    if (self.isSelf && self.myPostViewController) {
        [self.myPostViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.triangleBgImageView).offset(-44-44-44);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    } else if (self.otherUserFeedViewController) {
        if (self.shouldAdjustFeedHeight) {
            [self.otherUserFeedViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.triangleBgImageView).offset(-44-44-44);
                make.leading.equalTo(self.view);
                make.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        } else {
            [self.otherUserFeedViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.triangleBgImageView).offset(-44 - 20);
                make.leading.equalTo(self.view);
                make.trailing.equalTo(self.view);
                make.bottom.equalTo(self.view);
            }];
        }
    }
    
    [super updateViewConstraints];
}

#pragma mark - Navigation bar
- (void)loadRightBarButton
{
    if (self.isSelf) {
        FLYProfileEditButtonItem *barItem = [FLYProfileEditButtonItem barButtonItem:NO];
        @weakify(self)
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            @strongify(self)
            [self _editProfileTapped];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    }
}


#pragma mark - Tap events

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

- (void)_audioBioButtonTapped
{
    if (self.user.audioBioDuration > 0) {
        [self _playAudioBio];
    } else {
        [self _editAudioBio];
    }
}

- (void)_editAudioBio
{
    if (self.isSelf) {
        FLYRecordViewController *vc = [[FLYRecordViewController alloc] initWithRecordType:RecordingForAudioBio];
        FLYNavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navigationController animated:NO completion:nil];
    }
}

- (void)_editProfileTapped
{
    [self _editAudioBio];
}



- (void)_playAudioBio
{
    if (self.user.audioBioDuration > 0) {
        FLYAudioItem *newItem = [[FLYAudioItem alloc] initWithUrl:[NSURL URLWithString:self.user.audioBioURL] andCount:0 indexPath:nil itemType:FLYPlayableItemAudioBio playState:FLYPlayStateNotSet audioDuration:self.user.audioBioDuration];
        
        [[FLYAudioManager sharedInstance] updateAudioState:newItem];
        
        if (!self.audioBioPlaybackBg) {
            self.audioBioPlaybackBg = [UIImageView new];
            self.audioBioPlaybackBg.image = [UIImage imageNamed:@"icon_profile_playback_bg"];
            [self.view addSubview:self.audioBioPlaybackBg];
        }
        self.audioBioPlaybackBg.hidden = NO;
        
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _playbackIndicatorView.tintColor = [UIColor whiteColor];
        _playbackIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_playbackIndicatorView];
        _playbackIndicatorView.state = NAKPlaybackIndicatorViewStatePlaying;
        
        self.audioBioButton.hidden = YES;
        
        [self updateViewConstraints];
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
    [self _initTriangleBgView];
    [self _initBadgeView];
    [self _initBioView];
    [self _initAudioView];
    
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

- (void)_initTriangleBgView
{
    self.triangleBgImageView = [UIImageView new];
    self.triangleBgImageView.image = [UIImage imageNamed:@"icon_triangle_profile_bg"];
    [self.triangleBgImageView sizeToFit];
    [self.view insertSubview:self.triangleBgImageView belowSubview:self.topBgView];
}

- (void)_initBadgeView
{
    self.badgeView = [[FLYBadgeView alloc] initWithPoint:self.user.points];
    [self.view addSubview:self.badgeView];
}

- (void)_initBioView
{
    if (self.user.textBio) {
        self.bioTextView.text = self.user.textBio;
        self.bioTextView.alpha = 1;
    } else {
        if (self.isSelf) {
            [self _setSelfDefaultBio];
        } else {
            [self _setOthersDefaultBio];
        }
    }
}

- (void)_initAudioView
{
    if (self.user.audioBioDuration > 0) {
        [self.audioBioButton setImage:[UIImage imageNamed:@"icon_profile_playback"] forState:UIControlStateNormal];
    } else {
        // User hasn't entered audio bio
        if (self.isSelf) {
            [self.audioBioButton setImage:[UIImage imageNamed:@"icon_profile_record_bio"] forState:UIControlStateNormal];
        } else {
            [self.audioBioButton setImage:[UIImage imageNamed:@"icon_profile_playback"] forState:UIControlStateNormal];
            self.audioBioButton.alpha = 0.44f;
            self.audioBioButton.enabled = NO;
        }
    }
}

- (void)_initOtherFeedView
{
    self.otherUserFeedViewController = [[FLYUserFeedViewController alloc] initWithUserId:self.user.userId];
    self.otherUserFeedViewController.isFullScreen = NO;
    [self addChildViewController:self.otherUserFeedViewController];
    [self.view insertSubview:self.otherUserFeedViewController.view belowSubview:self.topBgView];
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

- (void)_audioBioUpdated:(NSNotification *)notif
{
    [self _initAudioView];
}

- (void)_audioBioCompletedPlaying:(NSNotification *)notif
{
    FLYAudioItem *audioItem = [notif.userInfo objectForKey:kAudioItemkey];
    if (audioItem.itemType == FLYPlayableItemAudioBio) {
        self.playbackIndicatorView.state = NAKPlaybackIndicatorViewStateStopped;
        [self.playbackIndicatorView removeFromSuperview];
        self.playbackIndicatorView = nil;
        self.audioBioButton.hidden = NO;
        
        [self.audioBioPlaybackBg removeFromSuperview];
        self.audioBioPlaybackBg = nil;
    }
}

#pragma mark - TextView

- (void)_setSelfDefaultBio
{
    self.bioTextView.text = LOC(@"FLYProfileBioSelfDefault");
    self.bioTextView.alpha = 0.44;
}

- (void)_setOthersDefaultBio
{
    self.bioTextView.text = LOC(@"FLYProfileBioOthersDefault");
    self.bioTextView.alpha = 0.44;
}

- (CGFloat)_getBioTextHeight:(NSString *)bio
{
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - kProfileBioTextLeftMargin - kProfileBioTextLeftMargin - 2.0 * self.bioTextView.textContainerInset.left;
    CGRect rect = [bio boundingRectWithSize:CGSizeMake(maxWidth, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont flyFontWithSize:19], NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle]} context:nil];
    return rect.size.height + 5;
}

#pragma mark - YYTextViewDelegate

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView
{
    if (!self.isSelf) {
        return NO;
    }
    
    self.bioTextView.alpha = 1.0f;
    if ([textView.text isEqualToString:LOC(@"FLYProfileBioSelfDefault")]) {
        textView.text = @"";
        textView.selectedRange = NSMakeRange(0, 0);
    }
    return YES;
}

- (void)textViewDidEndEditing:(YYTextView *)textView
{
    NSString *cleanStr = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (cleanStr == nil || [cleanStr isEqualToString:@""]) {
        [FLYUsersService updateTextBio:nil isDelete:YES successBlock:nil error:nil];
    } else {
        [FLYUsersService updateTextBio:textView.text isDelete:NO successBlock:nil error:nil];
    }
    if ([cleanStr isEqualToString:@""]) {
        [self _setSelfDefaultBio];
    }
    
    self.user.textBio = textView.text;
    [self updateViewConstraints];
}

- (void)textViewDidChange:(YYTextView *)textView
{
    NSUInteger maxNumberOfLines = 3;
    NSUInteger numLines = textView.contentSize.height / textView.font.lineHeight;
    if (self.currentNumberOfBioLines != numLines) {
        [self updateViewConstraints];
    }
    
    if (numLines > maxNumberOfLines)
    {
        textView.text = [textView.text substringToIndex:textView.text.length - 1];
        [Dialog simpleToast:@"Your bio cannot be more than 3 lines"];
    }
}

- (void)_loadProfileOnboarding
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(YES) forKey:kProfileAudioBioOnboardingKey];
    [defaults synchronize];
    if (self.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[FLYMainViewController class]]) {
        FLYMainViewController *mainVC = (FLYMainViewController *)self.parentViewController.parentViewController;
        [FLYProfileOnboardingView showFeedOnBoardViewWithMainVC:mainVC inViewController:self];
    }
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
