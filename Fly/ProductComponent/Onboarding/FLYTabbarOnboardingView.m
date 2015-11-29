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
@property (nonatomic) UILabel *profileLabel;
@property (nonatomic) UIImageView *profileArrow;

@property (nonatomic) UIView *bottomBackgrounLeftView;
@property (nonatomic) UIView *bottomBackgrounRightView;

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

        _profileLabel = [UILabel new];
        _profileLabel.textColor = [UIColor whiteColor];
        _profileLabel.font = font;
        _profileLabel.text = LOC(@"FLYTabbarOnboardingProfileButton");
        _profileLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_profileLabel];
        
        _profileArrow = [UIImageView new];
        _profileArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_profileArrow];
        
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
    FLYTabView *groupsTab = self.mainViewController.groupsTab;
    FLYTabView *recordTab = self.mainViewController.recordTab;
    FLYTabView *meTab = self.mainViewController.meTab;
    
    [self.homefeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(homeTab);
        make.bottom.equalTo(homeTab.mas_top).offset(-35);
    }];
    
    [self.homefeedArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.homefeedLabel);
        make.top.equalTo(self.homefeedLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(tabbarView.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.tagsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(groupsTab);
        make.bottom.equalTo(groupsTab.mas_top).offset(-35);
    }];
    
    [self.tagsArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tagsLabel);
        make.top.equalTo(self.tagsLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(tabbarView.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.recordPostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(recordTab);
        make.bottom.equalTo(recordTab.mas_top).offset(-35);
    }];
    
    [self.recordPostArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.recordPostLabel);
        make.top.equalTo(self.recordPostLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(recordTab.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.profileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(meTab);
        make.bottom.equalTo(meTab.mas_top).offset(-35);
    }];
    
    [self.profileArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.profileLabel);
        make.top.equalTo(self.profileLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(meTab.mas_top).offset(-kLabelTitleSpacing);
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
