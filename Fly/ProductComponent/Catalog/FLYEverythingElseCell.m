//
//  FLYEverythingElseCell.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYEverythingElseCell.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"

@interface FLYEverythingElseCell()

@property (nonatomic) UIView *containerView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UILabel *titleLabel;

@end

@implementation FLYEverythingElseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _containerView = [UIView new];
//        _containerView.backgroundColor = [UIColor colorWithHexString:@"#EBEFF1"];
        [self.contentView addSubview:_containerView];
        
        _backgroundImageView = [UIImageView new];
        [_containerView addSubview:_backgroundImageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor flyBlue];
        _titleLabel.font = [UIFont flyFontWithSize:25];
        [_containerView addSubview:_titleLabel];
    }
    return self;
}

- (void)configCellWithImage:(NSString *)imageName text:(NSString *)text
{
    self.backgroundImageView.image = [UIImage imageNamed:imageName];
    self.titleLabel.text = text;
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(25);
        make.leading.equalTo(self).offset(16);
        make.trailing.equalTo(self).offset(-16);
        make.bottom.equalTo(self);
    }];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [super updateConstraints];
}

@end
