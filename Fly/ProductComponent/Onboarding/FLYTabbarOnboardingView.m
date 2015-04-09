//
//  FLYTabbarOnboardingView.m
//  Flyy
//
//  Created by Xingxing Xu on 4/9/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTabbarOnboardingView.h"
#import "FLYMainViewController.h"
#import "FLYTabView.h"
#import "FLYTabBarView.h"
#import "UIFont+FLYAddition.h"

#define kLabelTitleSpacing 2
#define kBackgroundAlpha 0.75

@interface FLYTabbarOnboardingView()

@property (nonatomic) UIView *topBackgroundView;
@property (nonatomic) UILabel *homefeedLabel;
@property (nonatomic) UIImageView *homefeedArrow;
@property (nonatomic) UILabel *recordPostLabel;
@property (nonatomic) UIImageView *recordPostArrow;
@property (nonatomic) UILabel *tagsLabel;
@property (nonatomic) UIImageView *tagsArrow;

@property (nonatomic) UIView *bottomBackgrounLeftView;
@property (nonatomic) UIView *bottomBackgrounRightView;

// fake recording button. Only used for tutorial
@property (nonatomic) UIButton *recordButton;

@property (nonatomic) UIButton *tapContinueButton;

// tap gesture recognizer
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;

@end

@implementation FLYTabbarOnboardingView

- (instancetype)init
{
    if (self = [super init]) {
        
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        _topBackgroundView = [UIView new];
        _topBackgroundView.backgroundColor = [UIColor blackColor];
        _topBackgroundView.alpha = kBackgroundAlpha;
        [self addSubview:_topBackgroundView];
        
        UIFont *font = [UIFont fontWithName:@"Avenir-Black" size:18];
        _homefeedLabel = [UILabel new];
        _homefeedLabel.textColor = [UIColor whiteColor];
        _homefeedLabel.font = font;
        _homefeedLabel.text = LOC(@"FLYTabbarOnboardingHomeFeed");
        _homefeedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_homefeedLabel];
        
        _homefeedArrow = [UIImageView new];
        _homefeedArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_homefeedArrow];
        
        _recordPostLabel = [UILabel new];
        _recordPostLabel.textColor = [UIColor whiteColor];
        _recordPostLabel.font = font;
        _recordPostLabel.text = LOC(@"FLYTabbarOnboardingRecordButton");
        _recordPostLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_recordPostLabel];
        
        _recordPostArrow = [UIImageView new];
        _recordPostArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_recordPostArrow];
        
        _tagsLabel = [UILabel new];
        _tagsLabel.textColor = [UIColor whiteColor];
        _tagsLabel.font = font;
        _tagsLabel.text = LOC(@"FLYTabbarOnboardingTags");
        _tagsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_tagsLabel];
        
        _tagsArrow = [UIImageView new];
        _tagsArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_tagsArrow];

        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.userInteractionEnabled = NO;
        [_recordButton setImage:[UIImage imageNamed:@"icon_home_record"] forState:UIControlStateNormal];
        [self addSubview:_recordButton];
        
        _tapContinueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tapContinueButton.userInteractionEnabled = NO;
        [_tapContinueButton setBackgroundImage:[UIImage imageNamed:@"icon_tap_continue"] forState:UIControlStateNormal];
        [_tapContinueButton setTitle:LOC(@"FLYFeedOnboardingTapContinue") forState:UIControlStateNormal];
        _tapContinueButton.titleLabel.textColor = [UIColor whiteColor];
        _tapContinueButton.titleLabel.font = [UIFont flyFontWithSize:18];
        [self addSubview:_tapContinueButton];
    }
    return self;
}

- (void)updateConstraints
{
    [self.topBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-44);
    }];
    
    FLYTabBarView *tabbarView = self.mainViewController.tabBarView;
    
    FLYTabView *homeTab = self.mainViewController.homeTab;
    UIButton *recordingTab = self.mainViewController.recordButton;
    FLYTabView *tagsTab = self.mainViewController.groupsTab;
    
    [self.homefeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(homeTab);
        make.bottom.equalTo(homeTab.mas_top).offset(-35);
    }];
    
    [self.homefeedArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.homefeedLabel);
        make.top.equalTo(self.homefeedLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(tabbarView.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.recordPostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(recordingTab);
        make.bottom.equalTo(recordingTab.mas_top).offset(-75);
    }];
    
    [self.tagsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tagsTab);
        make.bottom.equalTo(tagsTab.mas_top).offset(-35);
    }];
    
    [self.tagsArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tagsLabel);
        make.top.equalTo(self.tagsLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(tabbarView.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.recordPostArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.recordPostLabel);
        make.top.equalTo(self.recordPostLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.recordButton.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.tapContinueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)tappedOnView:(UITapGestureRecognizer *)gr
{
    [self removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}

@end
