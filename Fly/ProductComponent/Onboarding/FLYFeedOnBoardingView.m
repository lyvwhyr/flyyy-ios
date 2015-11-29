//
//  FLYFeedOnBoardingView.m
//  Flyy
//
//  Created by Xingxing Xu on 4/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYFeedOnBoardingView.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYIconButton.h"
#import "UIFont+FLYAddition.h"
#import "FLYMainViewController.h"
#import "FLYTabbarOnboardingView.h"

#define kLabelTitleSpacing 2
#define kBackgroundAlpha 0.75

@interface FLYFeedOnBoardingView()

@property (nonatomic) UIView *topBackgroundView;
@property (nonatomic) UIView *bottomBackgroundView;

// down arrow
@property (nonatomic) UILabel *playPostLabel;
@property (nonatomic) UIImageView *playPostArrow;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *titleArrow;
@property (nonatomic) UILabel *votesLabel;
@property (nonatomic) UIImageView *votesArrow;

// up arrow
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UIImageView *usernameArrow;
@property (nonatomic) UILabel *groupNameLabel;
@property (nonatomic) UIImageView *groupNameArrow;
@property (nonatomic) UILabel *commentsLabel;
@property (nonatomic) UIImageView *commentsArrow;

@property (nonatomic) UIButton *tapContinueButton;

// bottom tabbar onboarding view
@property (nonatomic) FLYTabbarOnboardingView *tabbarOnboardingView;

// tap gesture recognizer
@property (nonatomic) UITapGestureRecognizer *gestureRecognizer;


@end

@implementation FLYFeedOnBoardingView

- (instancetype)initWithCell:(FLYFeedTopicTableViewCell *)onboardingCell
{
    if(self = [super init]) {
        _cellToExplain = onboardingCell;
        
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        _topBackgroundView = [UIView new];
        _topBackgroundView.backgroundColor = [UIColor blackColor];
        _topBackgroundView.alpha = kBackgroundAlpha;
        _topBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topBackgroundView];
        
        _bottomBackgroundView = [UIView new];
        _bottomBackgroundView.backgroundColor = [UIColor blackColor];
        _bottomBackgroundView.alpha = kBackgroundAlpha;
        _bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_bottomBackgroundView];
        
        // play post
        UIFont *font = [UIFont fontWithName:@"Avenir-Black" size:18];
        _playPostLabel = [UILabel new];
        _playPostLabel.textColor = [UIColor whiteColor];
        _playPostLabel.font = font;
        _playPostLabel.text = LOC(@"FLYFeedOnboardingPlayPost");
        _playPostLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_playPostLabel];
        
        _playPostArrow = [UIImageView new];
        _playPostArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        _playPostArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_playPostArrow];
        
        // topic title
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = font;
        _titleLabel.text = LOC(@"FLYFeedOnboardingTitle");
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];
        
        _titleArrow = [UIImageView new];
        _titleArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        _titleArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleArrow];
        
        // vote
        _votesLabel = [UILabel new];
        _votesLabel.textColor = [UIColor whiteColor];
        _votesLabel.font = font;
        _votesLabel.text = LOC(@"FLYFeedOnboardingVotes");
        _votesLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_votesLabel];
        
        _votesArrow = [UIImageView new];
        _votesArrow.image = [UIImage imageNamed:@"icon_down_arrow"];
        _votesArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_votesArrow];
        
        // user name
        _usernameLabel = [UILabel new];
        _usernameLabel.textColor = [UIColor whiteColor];
        _usernameLabel.font = font;
        _usernameLabel.text = LOC(@"FLYFeedOnboardingUsername");
        _usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_usernameLabel];
        
        _usernameArrow = [UIImageView new];
        _usernameArrow.image = [UIImage imageNamed:@"icon_up_arrow"];
        _usernameArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_usernameArrow];
        
        
        // comments
        _commentsLabel = [UILabel new];
        _commentsLabel.textColor = [UIColor whiteColor];
        _commentsLabel.font = font;
        _commentsLabel.text = LOC(@"FLYFeedOnboardingComments");
        _commentsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_commentsLabel];
        
        _commentsArrow = [UIImageView new];
        _commentsArrow.image = [UIImage imageNamed:@"icon_up_arrow"];
        _commentsArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_commentsArrow];
        
        _tapContinueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tapContinueButton.userInteractionEnabled = NO;
        [_tapContinueButton setBackgroundImage:[UIImage imageNamed:@"icon_tap_continue"] forState:UIControlStateNormal];
        [_tapContinueButton setTitle:LOC(@"FLYFeedOnboardingTapContinue") forState:UIControlStateNormal];
        _tapContinueButton.titleLabel.textColor = [UIColor whiteColor];
        _tapContinueButton.titleLabel.font = [UIFont flyFontWithSize:18];
        _tapContinueButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_tapContinueButton];
    }
    return self;
}

+ (UIView *)showFeedOnBoardViewWithCellToExplain:(FLYFeedTopicTableViewCell *)cell mainVC:(FLYMainViewController *)mainVC
{
    
    FLYFeedOnBoardingView *onboardingView = [[FLYFeedOnBoardingView alloc] initWithCell:cell];
    onboardingView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    onboardingView.mainViewController = mainVC;
    onboardingView.showInView = [[UIApplication sharedApplication] keyWindow];
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

- (void)updateConstraints
{
    [self.topBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        
        make.bottom.equalTo(self.cellToExplain.mas_top).offset(kStatusBarHeight + kNavBarHeight);
    }];
    
    [self.bottomBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cellToExplain.mas_bottom).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    // play post button
    [self.playPostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.playButton).offset(15);
        make.bottom.equalTo(self.topBackgroundView.mas_bottom).offset(-12);
    }];
    
    [self.playPostArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.playButton).offset(4);
        make.top.equalTo(self.playPostLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.cellToExplain.playButton.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    // topic title
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_cellToExplain.topicTitleLabel);
        make.bottom.equalTo(self.topBackgroundView.mas_bottom).offset(-37);
    }];
    
    [self.titleArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.topicTitleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.cellToExplain.topicTitleLabel.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    
    // vote
    [self.votesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.likeButton).offset(-6);
        make.bottom.equalTo(self.topBackgroundView.mas_bottom).offset(-12);
    }];
    
    [self.votesArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.likeButton);
        make.top.equalTo(self.votesLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.cellToExplain.likeButton.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    // user name
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.cellToExplain.userNameLabel).offset(2);
        make.top.equalTo(self.bottomBackgroundView.mas_top).offset(19);
    }];
    
    [self.usernameArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.usernameLabel);
        make.top.equalTo(self.cellToExplain.userNameLabel.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.usernameLabel.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    // comment
    [self.commentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.commentButton).offset(-26);
        make.top.equalTo(self.bottomBackgroundView.mas_top).offset(19);
    }];
    
    [self.commentsArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cellToExplain.commentButton);
        make.top.equalTo(self.cellToExplain.commentButton.mas_bottom).offset(kLabelTitleSpacing);
        make.bottom.equalTo(self.commentsLabel.mas_top).offset(-kLabelTitleSpacing);
    }];
    
    [self.tapContinueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomBackgroundView);
        make.centerY.equalTo(self.bottomBackgroundView);
    }];
    
    [super updateConstraints];
}

- (void)tappedOnView:(UITapGestureRecognizer *)gr
{
    [self removeFromSuperview];
    
    if (self.mainViewController) {
        _tabbarOnboardingView = [FLYTabbarOnboardingView new];
        _tabbarOnboardingView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        _tabbarOnboardingView.mainViewController = self.mainViewController;
        [self.showInView addSubview:_tabbarOnboardingView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}


@end
