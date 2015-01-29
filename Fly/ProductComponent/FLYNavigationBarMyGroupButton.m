//
//  FLYNavigationBarButton.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYNavigationBarMyGroupButton.h"
#import "UIColor+FLYAddition.h"

#define kMyGroupButtonHorizontalPadding 1

@interface FLYNavigationBarMyGroupButton()

@property (nonatomic) UIImageView *localIconView;
@property (nonatomic) UILabel *localTitleLabel;

@end

@implementation FLYNavigationBarMyGroupButton

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title icon:(NSString *)iconName
{
    if (self = [super init]) {
        self.frame = frame;
        _localIconView = [UIImageView new];
        [_localIconView setImage:[UIImage imageNamed:iconName]];
        [self addSubview:_localIconView];
        
        _localTitleLabel = [UILabel new];
        _localTitleLabel.text = title;
        _localTitleLabel.textColor = [UIColor flyBlue];
        _localTitleLabel.font = [UIFont fontWithName:@"HelveticaNeueInterface-MediumP4" size:17];
        [_localTitleLabel sizeToFit];
        [self addSubview:_localTitleLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(_localTitleLabel.bounds.size.width + 24 + kMyGroupButtonHorizontalPadding, 32);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _localTitleLabel.frame = CGRectMake(0, 5, _localTitleLabel.bounds.size.width, _localTitleLabel.bounds.size.height);
    _localIconView.frame = CGRectMake(_localTitleLabel.bounds.size.width + kMyGroupButtonHorizontalPadding, 5, 24, 24);
}

@end
