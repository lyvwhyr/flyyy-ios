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

@interface FLYFollowUserTableViewCell()

@property (nonatomic) UIImageView *badgeImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *pointsLabel;
@property (nonatomic) UIButton *followButton;

@end

@implementation FLYFollowUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _badgeImageView = [UIImageView new];
        _badgeImageView.image = [UIImage imageNamed:@"icon_profile_badge_heart"];
        [_badgeImageView sizeToFit];
        [self addSubview:_badgeImageView];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.textColor = [UIColor flyFollowUserTextColor];
        _userNameLabel.font = [UIFont flyLightFontWithSize:19];
        [self addSubview:_userNameLabel];
        
        _pointsLabel = [UILabel new];
        _pointsLabel.textColor = [UIColor flyFollowUserTextColor];
        _pointsLabel.font = [UIFont flyFontWithSize:16];
        [self addSubview:_pointsLabel];
        
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followButton setImage:[UIImage imageNamed:@"icon_follow_user_grey"] forState:UIControlStateNormal];
        [_followButton sizeToFit];
        [self addSubview:_followButton];
    }
    
    return self;
}

- (void)setupCellWithUser:(FLYUser *)user
{
    self.userNameLabel.text = user.userName;
    [self.userNameLabel sizeToFit];
    
    self.pointsLabel.text = @"234";
    [self.pointsLabel sizeToFit];
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(22);
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


@end
