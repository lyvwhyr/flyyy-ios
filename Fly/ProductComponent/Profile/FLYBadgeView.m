//
//  FLYBadgeView.m
//  Flyy
//
//  Created by Xingxing Xu on 11/15/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYBadgeView.h"
#import "UIFont+FLYAddition.h"
#import "FLYBadgeHelper.h"

#define kBadgeImageSize 24

@interface FLYBadgeView()

@property (nonatomic) UIImageView *bgImageView;
@property (nonatomic) UIImageView *badgeImageView;
@property (nonatomic) UILabel *pointLabel;

@property (nonatomic) NSInteger point;

@end

@implementation FLYBadgeView

- (instancetype)initWithPoint:(NSInteger)point
{
    if (self = [super init]) {
        _point = point;
        
        _bgImageView = [UIImageView new];
        _bgImageView.image = [UIImage imageNamed:@"icon_profile_badge_bg"];
        [_badgeImageView sizeToFit];
        [self addSubview:_bgImageView];
        
        _badgeImageView = [UIImageView new];
        NSInteger level = [FLYBadgeHelper getLevelForPoints:_point];
        _badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", @"icon_badge_l", level]];
        [_badgeImageView sizeToFit];
        [self addSubview:_badgeImageView];
        
        _pointLabel = [UILabel new];
        _pointLabel.text = [NSString stringWithFormat:@"%ld", _point];
        _pointLabel.textColor = [UIColor whiteColor];
        _pointLabel.font = [UIFont flyFontWithSize:15];
        [_pointLabel sizeToFit];
        [self addSubview:_pointLabel];
        
        [self _addConstraints];
    }
    return self;
}

- (void)_addConstraints
{
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.centerX.equalTo(self);
    }];
    
    [self.pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.badgeImageView.mas_bottom).offset(5);
        make.centerX.equalTo(self.badgeImageView);
    }];
}

@end
