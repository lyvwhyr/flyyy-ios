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
#import "AERecorder.h"
#import "AEAudioController.h"
#import "FLYAudioStateManager.h"
#import "FLYPrePostViewController.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150


@interface FLYRecordViewController ()

@property (nonatomic) FLYCircleView *innerCircleView;
@property (nonatomic) FLYCircleView *outerCircleView;
@property (nonatomic) UIImageView *userActionImageView;
@property (nonatomic) UILabel *recordedTimeLabel;
@property (nonatomic) SVPulsingAnnotationView *pulsingView;
@property (nonatomic, weak) PulsingHaloLayer *halo;
@property (nonatomic) UIButton *trashButton;
@property (nonatomic) FLYRecordState currentState;
@property (nonatomic) NSTimer *recordTimer;
@property (nonatomic) PulsingHaloLayer *pulsingHaloLayer;

@property (nonatomic) AEAudioController *audioController;
@property (nonatomic) AEAudioFilePlayer *audioPlayer;
@property (nonatomic, copy) AudioPlayerCompleteblock completionBlock;

@property (nonatomic, readonly) UITapGestureRecognizer *userActionTapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *deleteRecordingTapGestureRecognizer;

@property (nonatomic) NSInteger recordedSeconds;
@property (nonatomic) NSTimer *levelsTimer;

@end

@implementation FLYRecordViewController


- (instancetype)init
{
    if (self = [super init]) {
        self.view.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.title = @"Record";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _recordedSeconds = 0;
    [self _initVoiceRecording];
    
    [self _setupInitialViewState];
    [self _setupNavigationItem];
    
    [self updateViewConstraints];
}

- (void)_initVoiceRecording
{
    __weak typeof(self) weakSelf = self;
    _completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.currentState = FLYRecordCompleteState;
        [strongSelf.userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
    };
}

- (void)updateLevels:(NSTimer*)timer
{
    Float32 inputAvg, inputPeak, outputAvg, outputPeak;
    [_audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:&inputPeak];
    [_audioController outputAveragePowerLevel:&outputAvg peakHoldLevel:&outputPeak];
    
    float voicePower = translate(inputAvg, -20, 0);
    
    if (voicePower > 0) {
        NSLog(@"voice: %f", voicePower);
    }
    
    if (0<voicePower<=0.06) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<voicePower<=0.13) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<voicePower<=0.20) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<voicePower<=0.27) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<voicePower<=0.34) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<voicePower<=0.41) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<voicePower<=0.48) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<voicePower<=0.55) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<voicePower<=0.62) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<voicePower<=0.69) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<voicePower<=0.76) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<voicePower<=0.83) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<voicePower<=0.9) {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.userActionImageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
    
}

static inline float translate(float val, float min, float max) {
    if ( val < min ) val = min;
    if ( val > max ) val = max;
    return (val - min) / (max - min);
}

- (void)dealloc
{
    NSLog(@"dealloc for record view controller");
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(_nextBarButtonTapped)];
    
}

- (void)_backButtonTapped
{
    [self _cleanupData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_nextBarButtonTapped
{
    FLYPrePostViewController *prePostVC = [FLYPrePostViewController new];
    [self.navigationController pushViewController:prePostVC animated:YES];
}

- (void)_setupInitialViewState
{
    [_trashButton removeFromSuperview];
    _trashButton = nil;
    
    self.view.backgroundColor = [UIColor flyContentBackgroundGrey];
    _currentState = FLYRecordInitialState;
    
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
    
    [self updateViewConstraints];
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
    
    [[FLYAudioStateManager manager] startRecord];
    _audioPlayer = [FLYAudioStateManager manager].player;
    _audioController = [FLYAudioStateManager manager].audioController;
    
    self.levelsTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateLevels:) userInfo:nil repeats:YES];
}

- (void)_setupCompleteViewState
{
    [self.recordedTimeLabel removeFromSuperview];
    [_pulsingHaloLayer removeFromSuperlayer];
    
    _innerCircleView.hidden = YES;
    
    [_outerCircleView setupLayerFillColor:[UIColor whiteColor] strokeColor:[UIColor flyLightGreen]];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
    
    _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_trashButton setImage:[UIImage imageNamed:@"icon_record_trash_bin"] forState:UIControlStateNormal];
    _trashButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_trashButton addTarget:self action:@selector(_setupInitialViewState) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_trashButton];
    [self updateViewConstraints];
}

- (void)_setupPauseViewState
{
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_pause"]];
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
    _pulsingHaloLayer = [PulsingHaloLayer layer];
    self.halo = _pulsingHaloLayer;
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
    
    if (_currentState == FLYRecordRecordingState) {
        [self.recordedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.outerCircleView.mas_top).with.offset(-20);
            make.centerX.equalTo(self.outerCircleView.mas_centerX);
        }];
    }
    
    if (self.trashButton) {
        [self.trashButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.outerCircleView.mas_bottom).offset(30);
            make.right.equalTo(self.view.mas_right).offset(-30);
        }];
    }
    
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
        case FLYRecordRecordingState:
        {
            _currentState = FLYRecordCompleteState;
            [self _setupCompleteViewState];
            [[FLYAudioStateManager manager] stopRecord];
            break;
        }
        case FLYRecordCompleteState:
        {
            _currentState = FLYRecordPauseState;
            [self _setupPauseViewState];
            [[FLYAudioStateManager manager] playWithCompletionBlock:_completionBlock];
            break;
        }
        case FLYRecordPauseState:
        {
            _currentState = FLYRecordCompleteState;
            [[FLYAudioStateManager manager] playWithCompletionBlock:_completionBlock];
            [self _setupCompleteViewState];
            
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
