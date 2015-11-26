//
//  FLYShareFriendTableViewCell.m
//  Flyy
//
//  Created by Xingxing Xu on 11/26/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYShareFriendTableViewCell.h"

@interface FLYShareFriendTableViewCell()

@property (nonatomic) UIImageView *inviteImageView;
@property (nonatomic) UILabel *inviteTextLabel;

@end

@implementation FLYShareFriendTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _inviteImageView = [UIImageView new];
        [self.contentView addSubview:_inviteImageView];
        
        _inviteTextLabel = [UILabel new];
        _inviteTextLabel.textColor = [UIColor flyFollowUserTextColor];
        _inviteTextLabel.font = [UIFont flyFontWithSize:19];
        [self.contentView addSubview:_inviteTextLabel];
    }
    return self;
}

- (void)configCellWithImage:(NSString *)imageName text:(NSString *)text
{
    self.inviteImageView.image = [UIImage imageNamed:imageName];
    [self.inviteImageView sizeToFit];
    
    self.inviteTextLabel.text = text;
    [self.inviteTextLabel sizeToFit];
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    [self.inviteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(22);
    }];
    
    [self.inviteTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self.inviteImageView.mas_trailing).offset(16);
    }];
    
    [super updateConstraints];
}

@end
