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
        _userNameLabel.text = @"pancake";
        _userNameLabel.textColor = [UIColor flyBlue];
        _userNameLabel.font = [UIFont flyLightFontWithSize:19];
        [_userNameLabel sizeToFit];
        [self addSubview:_userNameLabel];
    }
    [self updateConstraints];
    
    return self;
}

- (void)updateConstraints
{
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(22);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.badgeImageView);
        make.leading.equalTo(self.badgeImageView.mas_trailing).offset(35);
    }];
    
    [super updateConstraints];
}


@end
