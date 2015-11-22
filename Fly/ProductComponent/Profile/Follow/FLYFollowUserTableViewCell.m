//
//  FLYFollowUserTableViewCell.m
//  Flyy
//
//  Created by Xingxing Xu on 11/16/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFollowUserTableViewCell.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"
#import "FLYUser.h"
#import "FLYBadgeHelper.h"

#define kBadgeSize 30

@interface FLYFollowUserTableViewCell()

@property (nonatomic) UIView *badgeView;
@property (nonatomic) UIImageView *badgeImageView;

@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *pointsLabel;
@property (nonatomic) UIButton *followButton;

@property (nonatomic) FLYUser *user;

@end

@implementation FLYFollowUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _badgeView = [UIView new];
        [self addSubview:_badgeView];
        
        _badgeImageView = [UIImageView new];
        _badgeImageView.image = [UIImage imageNamed:@"icon_profile_badge_heart"];
        [_badgeImageView sizeToFit];
        [_badgeView addSubview:_badgeImageView];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.textColor = [UIColor flyFollowUserTextColor];
        _userNameLabel.font = [UIFont flyLightFontWithSize:19];
        [self addSubview:_userNameLabel];
        
        _pointsLabel = [UILabel new];
        _pointsLabel.textColor = [UIColor flyFollowUserTextColor];
        _pointsLabel.font = [UIFont flyFontWithSize:16];
        [self addSubview:_pointsLabel];
        
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followButton addTarget:self action:@selector(_followButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_followButton setImage:[UIImage imageNamed:@"icon_follow_user_grey"] forState:UIControlStateNormal];
        [_followButton sizeToFit];
        [self addSubview:_followButton];
        
        [self _addObservers];
    }
    
    return self;
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_followUpdated:) name:kNotificationFollowUserChanged object:nil];
}

- (void)setupCellWithUser:(FLYUser *)user
{
    self.user = user;
    
    self.userNameLabel.text = user.userName;
    [self.userNameLabel sizeToFit];
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", user.points];
    [self.pointsLabel sizeToFit];
    
    if (user.isFollowing) {
        [self.followButton setImage:[UIImage imageNamed:@"icon_unfollow_user_grey"] forState:UIControlStateNormal];
    } else {
        [self.followButton setImage:[UIImage imageNamed:@"icon_follow_user_grey"] forState:UIControlStateNormal];
    }
    
    NSInteger level = [FLYBadgeHelper getLevelForPoints:self.user.points];
    self.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", @"icon_badge_l", level]];
    [self updateConstraints];
}

- (void)_followButtonTapped
{
    [self.user followUser];
}

- (void)updateConstraints
{
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(22);
        make.width.equalTo(@(kBadgeSize));
        make.height.equalTo(@(kBadgeSize));
    }];
    
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.badgeView);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.badgeImageView);
        make.leading.equalTo(self.badgeImageView.mas_trailing).offset(30);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-14);
    }];
    
    [self.pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self.followButton.mas_leading).offset(-25);
    }];
    
    [super updateConstraints];
}

#pragma mark - Follow notification

- (void)_followUpdated:(NSNotification *)notification
{
    FLYUser *user = [notification.userInfo objectForKey:@"user"];
    if ([user.userId isEqualToString:self.user.userId]) {
        if (user.isFollowing) {
            [self.followButton setImage:[UIImage imageNamed:@"icon_unfollow_user_grey"] forState:UIControlStateNormal];
        } else {
            [self.followButton setImage:[UIImage imageNamed:@"icon_follow_user_grey"] forState:UIControlStateNormal];
        }
    }
}


@end
