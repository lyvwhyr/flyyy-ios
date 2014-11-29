//
//  FLYIconButton.m
//  Fly
//
//  Created by Xingxing Xu on 11/28/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYIconButton.h"
#import "UIColor+FLYAddition.h"

#define kIconRightPadding 5

@interface FLYIconButton()

@property (nonatomic) UILabel *localTitleLabel;
@property (nonatomic) UIImageView *localIconView;

@end

@implementation FLYIconButton

- (instancetype)initWithText:(NSString *)text textFont:(UIFont *)font textColor:(UIColor *)color icon:(NSString *)iconName
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _localIconView = [UIImageView new];
        _localIconView.translatesAutoresizingMaskIntoConstraints = NO;
        [_localIconView setImage:[UIImage imageNamed:iconName]];
        [_localIconView sizeToFit];
        [self addSubview:_localIconView];
        
        _localTitleLabel = [UILabel new];
        _localTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _localTitleLabel.text = text;
        _localTitleLabel.textColor = color;
        _localTitleLabel.font = font;
        
        [_localTitleLabel sizeToFit];
        [self addSubview:_localTitleLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [_localIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
    }];
    
    [_localTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(_localIconView.mas_right).offset(kIconRightPadding);
    }];
    
    [super updateConstraints];
    
}

- (CGSize)intrinsicContentSize
{
    CGFloat intrinsicHeight = MAX(CGRectGetHeight(_localIconView.bounds), CGRectGetHeight(_localTitleLabel.bounds));
    CGFloat intrinsicWidth = CGRectGetWidth(_localIconView.bounds) + CGRectGetWidth(_localTitleLabel.bounds) + kIconRightPadding;
    return CGSizeMake(intrinsicWidth, intrinsicHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

@end
