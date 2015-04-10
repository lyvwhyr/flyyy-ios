//
//  FLYReplyOnboardingView.m
//  Flyy
//
//  Created by Xingxing Xu on 4/9/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTopicDetailOnboardingView.h"
#import "FLYTopicDetailTabbar.h"
#import "FLYDashTextView.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "FLYTopicDetailViewController.h"

#define kOnboardingMaxWidth 250
#define kArrowSpacing 2
#define kPlayAllBottomPadding 46
#define kCommentBottomPadding 70
#define kBackgroundAlpha 0.75

@interface FLYTopicDetailOnboardingView()

@property (nonatomic) UIView *topBackgroundView;
@property (nonatomic) FLYDashTextView *explanationTextView;
@property (nonatomic) UILabel *commentLabel;
@property (nonatomic) UIImageView *commentArrow;
@property (nonatomic) UILabel *playAllLabel;
@property (nonatomic) UIImageView *playAllArrow;

// tap gesture recognizer
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;

@property (nonatomic) FLYTopicDetailViewController *topicDetailViewController;
@property (nonatomic) UIView *showInView;

@end

@implementation FLYTopicDetailOnboardingView

- (instancetype)init
{
    if (self = [super init]) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        _topBackgroundView = [UIView new];
        _topBackgroundView.backgroundColor = [UIColor blackColor];
        _topBackgroundView.alpha = kBackgroundAlpha;
        [self addSubview:_topBackgroundView];
        
        // comment
        UIFont *font = [UIFont flyFontWithSize:18];
        _commentLabel = [UILabel new];
        _commentLabel.textColor = [UIColor whiteColor];
        _commentLabel.font = font;
        _commentLabel.text = LOC(@"FLYTopicDetailOnboardingCommentButton");
        _commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_commentLabel];
        
        _commentArrow = [UIImageView new];
        _commentArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_commentArrow];
        
        // play all
        _playAllLabel = [UILabel new];
        _playAllLabel.textColor = [UIColor whiteColor];
        _playAllLabel.font = font;
        _playAllLabel.text = LOC(@"FLYTopicDetailOnboardingPlayallButton");
        _playAllLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_playAllLabel];
        
        _playAllArrow = [UIImageView new];
        _playAllArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        [self addSubview:_playAllArrow];
        
        // center text
        UIFont *highlightFont = [UIFont fontWithName:@"Avenir-black" size:18];
        UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
        _explanationTextView = [[FLYDashTextView alloc] initWithText:LOC(@"FLYTopicDetailOnboardingHintText") font:font color:[UIColor whiteColor] hightlightItems:@[LOC(@"FLYTopicDetailOnboardingHintHighlightPlayAll"), LOC(@"FLYTopicDetailOnboardingHintHighlightComment")] highlightFont:highlightFont edgeInsets:insets dashColor:FLYDashTextWhite maxLabelWidth:kOnboardingMaxWidth];
        [self addSubview:_explanationTextView];
    }
    return self;
}

+ (UIView *)showOnboardingWithFromViewController:(FLYTopicDetailViewController *)vc
{
    FLYTopicDetailOnboardingView *onboardingView = [FLYTopicDetailOnboardingView new];
    onboardingView.topicDetailViewController = vc;
    onboardingView.showInView = [[UIApplication sharedApplication] keyWindow];
    onboardingView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [onboardingView.showInView addSubview:onboardingView];
    [onboardingView _show];
    return nil;
}

- (void)_show
{
    self.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
}

- (void)updateConstraints
{
    [self.topBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self.topicDetailViewController.tabbar.mas_top);
    }];
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topicDetailViewController.tabbar.commentButton);
        make.bottom.equalTo(self.topicDetailViewController.tabbar.mas_top).offset(-kCommentBottomPadding);
    }];
    
    [self.commentArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentLabel.mas_bottom).offset(kArrowSpacing);
        make.centerX.equalTo(self.commentLabel);
        make.bottom.equalTo(self.topicDetailViewController.tabbar.mas_top).offset(-kArrowSpacing);
    }];
    
    [self.playAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topicDetailViewController.tabbar.playAllButton);
        make.bottom.equalTo(self.topicDetailViewController.tabbar.mas_top).offset(-kPlayAllBottomPadding);
    }];
    
    [self.playAllArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playAllLabel.mas_bottom).offset(kArrowSpacing);
        make.centerX.equalTo(self.playAllLabel);
        make.bottom.equalTo(self.topicDetailViewController.tabbar.mas_top).offset(-kArrowSpacing);
    }];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
    CGFloat textHeight = [FLYDashTextView geLabelHeightWithText:LOC(@"FLYTopicDetailOnboardingHintText") font:[UIFont flyFontWithSize:18] hightlightItems:@[LOC(@"FLYTopicDetailOnboardingHintHighlightPlayAll"), LOC(@"FLYTopicDetailOnboardingHintHighlightComment")] highlightFont:[UIFont fontWithName:@"Avenir-black" size:18] maxLabelWidth:kOnboardingMaxWidth];
    [self.explanationTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(-40);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        // add extra 2 points to give text enough height
        make.height.equalTo(@(textHeight + insets.top * 2));
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
