
//  FLYIconButton.m
//  Fly
//
//  Created by Xingxing Xu on 11/28/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYIconButton.h"
#import "UIColor+FLYAddition.h"
#import "CoreGraphics+FLYAddition.h"

#define kIconRightPadding 5

@interface FLYIconButton()

@property (nonatomic) UILabel *localTitleLabel;
@property (nonatomic) UIImageView *localIconView;

@property (nonatomic) BOOL isIconLeft;

@end

@implementation FLYIconButton

- (instancetype)initWithText:(NSString *)text textFont:(UIFont *)font textColor:(UIColor *)color icon:(NSString *)iconName isIconLeft:(BOOL)isIconLeft
{
    self = [super init];
    if (self) {
        _isIconLeft = isIconLeft;
        
        _localIconView = [UIImageView new];
        _localIconView.translatesAutoresizingMaskIntoConstraints = NO;
        [_localIconView setImage:[UIImage imageNamed:iconName]];
        [_localIconView sizeToFit];
        [self addSubview:_localIconView];
        
        _localTitleLabel = [UILabel new];
        _localTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _localTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _localTitleLabel.text = text;
        _localTitleLabel.textColor = color;
        _localTitleLabel.font = font;
        [_localTitleLabel sizeToFit];
        [self addSubview:_localTitleLabel];
    }
    return self;
}

- (void)setLabelText:(NSString *)text
{
    _localTitleLabel.text = text;
    [self updateConstraints];
}

- (void)setLabelTextColor:(UIColor *)color
{
    _localTitleLabel.textColor = color;
}

- (void)setIconImage:(UIImage *)image
{
    [_localIconView setImage:image];
    [_localIconView sizeToFit];
    [self updateConstraints];
}

- (void)updateConstraints
{
    CGFloat rightPadding = kIconRightPadding;
    if (self.overrideIconRightPadding > 0) {
        rightPadding = self.overrideIconRightPadding;
    }
    
    CGFloat intrinsicHeight = MAX(CGRectGetHeight(_localIconView.bounds), CGRectGetHeight(_localTitleLabel.bounds));
    CGFloat iconExtraOffset = FLYFloorToPixel((intrinsicHeight - CGRectGetHeight(_localIconView.bounds))/2);
    CGFloat labelExtraOffset = FLYFloorToPixel((intrinsicHeight - CGRectGetHeight(_localTitleLabel.bounds))/2);
    if (self.isIconLeft) {
        [_localIconView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(iconExtraOffset);
            make.leading.equalTo(self);
        }];
        
        [_localTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(labelExtraOffset);
            make.leading.equalTo(_localIconView.mas_right).offset(rightPadding);
        }];
    } else {
        [_localIconView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(iconExtraOffset);
            make.trailing.equalTo(self);
        }];
        
        [_localTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(labelExtraOffset);
            make.trailing.equalTo(self.localIconView.mas_leading).offset(-rightPadding);
        }];

    }
    [super updateConstraints];
    
}

- (CGSize)intrinsicContentSize
{
    CGFloat rightPadding = kIconRightPadding;
    if (self.overrideIconRightPadding > 0) {
        rightPadding = self.overrideIconRightPadding;
    }
    
    [_localTitleLabel sizeToFit];
    CGFloat intrinsicHeight = MAX(CGRectGetHeight(_localIconView.bounds), CGRectGetHeight(_localTitleLabel.bounds));
    CGFloat intrinsicWidth = CGRectGetWidth(_localIconView.bounds) + CGRectGetWidth(_localTitleLabel.bounds) + rightPadding;
    return CGSizeMake(intrinsicWidth, intrinsicHeight);
}

- (void)setisPressed:(BOOL)isPressed
{
    _isPressed = !isPressed;
}

@end
