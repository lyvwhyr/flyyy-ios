//
//  FLYPostButtonView.m
//  Fly
//
//  Created by Xingxing Xu on 12/12/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPostButtonView.h"
#import "UIColor+FLYAddition.h"

@interface FLYPostButtonView()

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIImageView *iconView;

@end

@implementation FLYPostButtonView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor flyBlue];
        
        _textLabel = [UILabel new];
        _textLabel.text = @"Post";
        _textLabel.textColor = [UIColor whiteColor];
        [self addSubview:_textLabel];
        
        _iconView = [ UIImageView new];
        [_iconView setImage:[UIImage imageNamed:@"icon_share_post"]];
        [self addSubview:_iconView];
        
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints
{
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(_textLabel.mas_trailing).offset(5);
    }];
    [super updateConstraints];
}

@end
