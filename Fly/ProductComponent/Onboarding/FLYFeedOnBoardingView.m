//
//  FLYFeedOnBoardingView.m
//  Flyy
//
//  Created by Xingxing Xu on 4/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYFeedOnBoardingView.h"
#import "FLYFeedTopicTableViewCell.h"

@interface FLYFeedOnBoardingView()

@property (nonatomic) UIView *topBackgroundView;
@property (nonatomic) UIView *bottomBackgroundView;

@end

@implementation FLYFeedOnBoardingView

- (instancetype)init
{
    if(self = [super init]) {
        _topBackgroundView = [UIView new];
        _topBackgroundView.backgroundColor = [UIColor blackColor];
        _topBackgroundView.alpha = 0.65;
        [self addSubview:_topBackgroundView];
        
        _bottomBackgroundView = [UIView new];
        _bottomBackgroundView.backgroundColor = [UIColor blackColor];
        _bottomBackgroundView.alpha = 0.65;
        [self addSubview:_bottomBackgroundView];
    }
    return self;
}

+ (UIView *)showFeedOnBoardViewInView:(UIView *)inView cellToExplain:(FLYFeedTopicTableViewCell *)cell
{
    
    FLYFeedOnBoardingView *onboardingView = [FLYFeedOnBoardingView new];
    onboardingView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    onboardingView.showInView = [[UIApplication sharedApplication] keyWindow];
    onboardingView.cellToExplain = cell;
    [onboardingView.showInView addSubview:onboardingView];
    return onboardingView;
}

- (void)updateConstraints
{
    [self.topBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self.cellToExplain.mas_top);
    }];
    
    [self.bottomBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cellToExplain.mas_bottom);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}


@end
