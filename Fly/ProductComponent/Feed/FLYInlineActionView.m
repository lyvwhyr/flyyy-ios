//
//  FLYInlineActionView.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYInlineActionView.h"
#import "FLYIconButton.h"
#import "UIColor+FLYAddition.h"


#define kInlineActionButtonTopPadding 10
#define kInlineActionButtonHorizontalPadding 50

@interface FLYInlineActionView()

@property (nonatomic) FLYIconButton *flyButton;
@property (nonatomic) FLYIconButton *commentButton;
@property (nonatomic) FLYIconButton *shareButton;

@end

@implementation FLYInlineActionView

- (instancetype)init
{
    if (self = [super init]) {
        UIColor *color = [UIColor flyInlineActionGrey];
        UIFont *font = [UIFont systemFontOfSize:13.0f];
        _flyButton = [[FLYIconButton alloc] initWithText:@"5" textFont:font textColor:color icon:@"icon_inline_wing"];
        [self addSubview:_flyButton];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"10" textFont:font textColor:color  icon:@"icon_inline_comment"];
        [self addSubview:_commentButton];
        
        _shareButton = [[FLYIconButton alloc] initWithText:@"Share" textFont:font textColor:color icon:@"icon_inline_share"];
        [self addSubview:_shareButton];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    
    [_flyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kInlineActionButtonTopPadding);
        make.leading.equalTo(self).offset(20 + 36 + 10);
    }];
    
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kInlineActionButtonTopPadding);
        make.leading.equalTo(_flyButton.mas_trailing).offset(kInlineActionButtonHorizontalPadding);
    }];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kInlineActionButtonTopPadding);
        make.leading.equalTo(_commentButton.mas_trailing).offset(kInlineActionButtonHorizontalPadding);
    }];
    
    [super updateConstraints];
}



@end
