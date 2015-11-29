//
//  FLYProfileOnboardingView.m
//  Flyy
//
//  Created by Xingxing Xu on 11/27/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYProfileOnboardingView.h"
#import "FLYMainViewController.h"
#import "FLYProfileViewController.h"
#import "FLYDashTextView.h"

#define kBackgroundAlpha 0.85
#define kOnboardingMaxWidth 250

@interface FLYProfileOnboardingView()

@property (nonatomic) UIView *showInView;
@property (nonatomic) FLYMainViewController *mainViewController;
@property (nonatomic) FLYProfileViewController *inViewController;

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIButton *recordButton;
@property (nonatomic) FLYDashTextView *explanationTextView;

@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;

@end

@implementation FLYProfileOnboardingView

- (instancetype)init
{
    if (self = [super init]) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = kBackgroundAlpha;
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_backgroundView];
        
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setImage:[UIImage imageNamed:@"icon_profile_record_bio"] forState:UIControlStateNormal];
        [_recordButton sizeToFit];
        [self addSubview:self.recordButton];
        
        // center text
        UIFont *font = [UIFont flyFontWithSize:18];
        UIFont *highlightFont = [UIFont fontWithName:@"Avenir-black" size:18];
        UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
        _explanationTextView = [[FLYDashTextView alloc] initWithText:LOC(@"FLYProfileOnboardingTapToRecord") font:font color:[UIColor whiteColor] hightlightItems:@[LOC(@"FLYProfileOnboardingTapToRecordTextHighlight")] highlightFont:highlightFont edgeInsets:insets dashColor:FLYDashTextWhite maxLabelWidth:kOnboardingMaxWidth];
        [self addSubview:_explanationTextView];
    }
    return self;
}


+ (UIView *)showFeedOnBoardViewWithMainVC:(FLYMainViewController *)mainVC inViewController:(FLYProfileViewController *)inViewController
{
    
    FLYProfileOnboardingView *onboardingView = [FLYProfileOnboardingView new];
    onboardingView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    onboardingView.mainViewController = mainVC;
    onboardingView.showInView = [[UIApplication sharedApplication] keyWindow];
    onboardingView.inViewController = inViewController;
    [onboardingView.showInView addSubview:onboardingView];

    [onboardingView _show];
    
    return onboardingView;
}

- (void)_show
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
}

- (void)tappedOnView:(UITapGestureRecognizer *)gr
{
    [self removeFromSuperview];
}

- (void)updateConstraints
{
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.inViewController.audioBioButton);
    }];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
    CGFloat textHeight = [FLYDashTextView geLabelHeightWithText:LOC(@"FLYProfileOnboardingTapToRecord") font:[UIFont flyFontWithSize:18] hightlightItems:@[LOC(@"FLYProfileOnboardingTapToRecordTextHighlight")] highlightFont:[UIFont fontWithName:@"Avenir-black" size:18] maxLabelWidth:kOnboardingMaxWidth];
    [self.explanationTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recordButton.mas_bottom).offset(40);
        make.leading.equalTo(self).offset(30);
        make.trailing.equalTo(self).offset(-30);
        // add extra 2 points to give text enough height
        make.height.equalTo(@(textHeight + insets.top * 2));
    }];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}

@end
