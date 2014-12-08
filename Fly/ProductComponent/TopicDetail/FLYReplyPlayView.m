//
//  FLYReplyPlayView.m
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYReplyPlayView.h"

@interface FLYReplyPlayView()

@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UIImageView *playIconView;
@property (nonatomic) UILabel *timeLabel;

@end

@implementation FLYReplyPlayView

- (instancetype)init
{
    if (self = [super init]) {
        _backgroundImageView = [UIImageView new];
        [_backgroundImageView setImage:[UIImage imageNamed:@"icon_seconds"]];
        [self addSubview:_backgroundImageView];
        [self sendSubviewToBack:_backgroundImageView];
        
        _timeLabel = [UILabel new];
        _timeLabel.text = @"24\"";
        [self addSubview:_timeLabel];
        
        _playIconView = [UIImageView new];
        [_playIconView setImage:[UIImage imageNamed:@"icon_play_reply"]];
         [self addSubview:_playIconView];
        
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints
{
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(self);
    }];
    
    [_playIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-10);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(10);
    }];
    
    [super updateConstraints];
}

@end
