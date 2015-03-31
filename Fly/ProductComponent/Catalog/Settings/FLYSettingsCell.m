//
//  FLYSettingsCell.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSettingsCell.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"

#define kTitleLeftPadding 25
#define kRightArrowRightPadding 15

@interface FLYSettingsCell()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *rightArrow;

@end

@implementation FLYSettingsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont flyFontWithSize:15];
        _titleLabel.textColor = [UIColor flyBlue];
        [self.contentView addSubview:_titleLabel];
        
        _rightArrow = [UIImageView new];
        _rightArrow.image = [UIImage imageNamed:@"icon_right_arrow"];
        [self.contentView addSubview:_rightArrow];
    }
    return self;
}

- (void)configCellWithTitle:(NSString *)title hideRightArrow:(BOOL)hide
{
    self.titleLabel.text = title;
    self.rightArrow.hidden = hide;
    [self updateConstraints];
}

- (void)updateConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kTitleLeftPadding);
        make.centerY.equalTo(self);
    }];
    
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-kRightArrowRightPadding);
        make.centerY.equalTo(self);
    }];
    
    [super updateConstraints];
}

@end
