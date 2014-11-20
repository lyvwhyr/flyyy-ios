//
//  FLYRecordViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYRecordViewController.h"
#import "FLYCircleView.h"
#import "UIColor+FLYAddition.h"
#import "SVPulsingAnnotationView.h"
#import "PulsingHaloLayer.h"
#import "MultiplePulsingHaloLayer.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150

@interface FLYRecordViewController ()

@property (nonatomic) FLYCircleView *innerCircleView;
@property (nonatomic) FLYCircleView *outerCircleView;
@property (nonatomic) UIImageView *userActionImageView;
@property (nonatomic) UILabel *recordedTimeLabel;
@property (nonatomic) SVPulsingAnnotationView *pulsingView;
@property (nonatomic, weak) PulsingHaloLayer *halo;
@property (nonatomic) FLYRecordState currentState;
@property (nonatomic) NSTimer *recordTimer;

@property (nonatomic, readonly) UITapGestureRecognizer *userActionTapGestureRecognizer;

@property (nonatomic) NSInteger recordedSeconds;

@end

@implementation FLYRecordViewController


- (instancetype)init
{
    if (self = [super init]) {
        self.view.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _recordedSeconds = 0;
    
    [self _setupInitialViewState];
    [self _setupNavigationItem];
    
    [self updateViewConstraints];
}

- (void)dealloc
{
    
}

- (void)_cleanupData
{
    [_recordTimer invalidate];
    _recordTimer = nil;
}

- (void)_setupNavigationItem
{
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navigation_back"] style:UIBarButtonItemStylePlain target:self action:@selector(_backButtonTapped)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    [backButton setImage:[UIImage imageNamed:@"icon_navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(_backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_setupInitialViewState
{
    self.view.backgroundColor = [UIColor flyContentBackgroundGrey];
    
    _outerCircleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kOuterCircleRadius, kOuterCircleRadius) radius:kOuterCircleRadius color:[UIColor whiteColor]];
    [self.view addSubview:_outerCircleView];
    
    _innerCircleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kInnerCircleRadius, kInnerCircleRadius) radius:kInnerCircleRadius color:[UIColor flyGreen]];
    [self.view insertSubview:_innerCircleView aboveSubview:_outerCircleView];
    
    _userActionImageView = [UIImageView new];
    _userActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_voice_record"]];
    _userActionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_userActionTapped:)];
    [_userActionImageView addGestureRecognizer:_userActionTapGestureRecognizer];
    _userActionImageView.userInteractionEnabled = YES;
    [self.view insertSubview:_userActionImageView aboveSubview:_innerCircleView];
}

- (void)_setupRecordingViewState
{
    self.recordedSeconds = 0;
    [self _setupRecordTimer];
    
    [_recordedTimeLabel removeFromSuperview];
    _recordedTimeLabel = [UILabel new];
    _recordedTimeLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:28.0f];
    _recordedTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _recordedTimeLabel.textColor = [UIColor flyGreen];
    
    [self.view addSubview:_recordedTimeLabel];
    [self _addPulsingAnimation];
    [self updateViewConstraints];
}

- (void)_setupRecordTimer
{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateTimerLabel) userInfo:nil repeats:YES];
}

- (void)_updateTimerLabel
{
    self.recordedSeconds++;
    _recordedTimeLabel.text = [NSString stringWithFormat:@"%ld s", self.recordedSeconds];
    [self.view setNeedsLayout];
}


- (void)_addPulsingAnimation
{
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    self.halo = layer;
    self.halo.radius = 150;
    [self.view.layer insertSublayer:self.halo below:self.userActionImageView.layer];
}

-(void)updateViewConstraints
{
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(@0);
//        make.top.equalTo(@(0));
//        make.width.equalTo(@(100));
//        make.height.equalTo(@(200));
//    }];
    
    [self.outerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kOuterCircleRadius * 2));
        make.height.equalTo(@(kOuterCircleRadius * 2));
        make.center.equalTo(self.view);
    }];
    
    
    [self.innerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kInnerCircleRadius * 2));
        make.height.equalTo(@(kInnerCircleRadius * 2));
        make.center.equalTo(self.view);
    }];
    
    [self.userActionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.innerCircleView);
    }];
    
    [self.recordedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.outerCircleView.mas_top).with.offset(-20);
        make.centerX.equalTo(self.outerCircleView.mas_centerX);
    }];
    
    [super updateViewConstraints];
}

- (void)_userActionTapped:(UIGestureRecognizer *)gestureRecognizer
{
    switch (_currentState) {
        case FLYRecordInitialState:
        {
            _currentState = FLYRecordRecordingState;
            [self _setupRecordingViewState];
            break;
        }
        default:
            break;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.halo.position = self.userActionImageView.center;
}

@end
