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
#import "GBFlatButton.h"
#import "DKCircleButton.h"
#import "FLYBarButtonItem.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"
#import "FLYRecordBottomBar.h"
#import "Waver.h"
#import "FLYEndpointRequest.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150
#define kOutCircleTopPadding 80
#define kFilterModalHeight 80
#define kMaxRetry 3
#define kTimeLabelTopPadding 30

@interface FLYRecordViewController ()<FLYRecordBottomBarDelegate>

@property (nonatomic) UIBarButtonItem *rightNavigationButton;

@property (nonatomic) FLYCircleView *innerCircleView;
@property (nonatomic) FLYCircleView *outerCircleView;
@property (nonatomic) UIImageView *userActionImageView;
@property (nonatomic) UILabel *recordedTimeLabel;
@property (nonatomic) UILabel *remainingTimeLabel;
@property (nonatomic) SVPulsingAnnotationView *pulsingView;
@property (nonatomic, weak) PulsingHaloLayer *halo;
@property (nonatomic) UIButton *trashButton;
@property (nonatomic) FLYRecordBottomBar *recordBottomBar;
@property (nonatomic) Waver *waver;

@property (nonatomic) FLYRecordState currentState;
@property (nonatomic) NSTimer *recordTimer;
@property (nonatomic) NSTimer *playbackTimer;
@property (nonatomic) PulsingHaloLayer *pulsingHaloLayer;
@property (nonatomic) DKCircleButton *voiceFilterButton;

@property (nonatomic, weak) AEAudioController *audioController;
@property (nonatomic, weak) AEAudioFilePlayer *audioPlayer;
@property (nonatomic, copy) AudioPlayerCompleteblock completionBlock;

@property (nonatomic, readonly) UITapGestureRecognizer *userActionTapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *deleteRecordingTapGestureRecognizer;

@property (nonatomic) NSInteger audioLength;
@property (nonatomic) NSInteger remainingAudioLength;
@property (nonatomic) NSTimer *levelsTimer;

@property (nonatomic) NSString *mediaId;
@property (nonatomic) NSInteger retryCount;

@end

@implementation FLYRecordViewController

#define kMaxRecordTime          60


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Set up title
    self.title = @"Record";
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.view.backgroundColor = [UIColor whiteColor];
    
    _audioLength = 0;
    [self _initVoiceRecording];
    
    [self _setupInitialViewState];
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)dealloc
{
    UALog(@"dealloc called");
    [self _cleanupData];
}

- (void)_initVoiceRecording
{
    @weakify(self)
    _completionBlock = ^{
        @strongify(self)
        //Set currentState to FLYRecordRecordingState, so next state will be complete state
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentState = FLYRecordRecordingState;
            [self _updateUserState];
        });
    };
}

- (void)updateLevels:(NSTimer*)timer
{
    if (_currentState != FLYRecordRecordingState) {
        return;
    }
    
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


#pragma mark - clean up 

- (void)_cleanupData
{
    [self _cleanupTimer];
    self.waver = nil;
}

- (void) _cleanupTimer
{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
}

#pragma mark - Navigation bar 

- (void)loadLeftBarButton
{
    FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
    @weakify(self)
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _backButtonTapped];
    };
    self.navigationItem.leftBarButtonItem = barItem;
}

-(void)loadRightBarButton
{
    if (self.currentState == FLYRecordCompleteState) {
        FLYPostRecordingNextBarButtonItem *barButtonItem = [FLYPostRecordingNextBarButtonItem barButtonItem:NO];
        @weakify(self)
        barButtonItem.actionBlock = ^(FLYBarButtonItem *item) {
            @strongify(self)
            [self _nextBarButtonTapped];
        };
        self.navigationItem.rightBarButtonItem = barButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


#pragma mark - navigation bar actions

- (void)_backButtonTapped
{
    [self _cleanupData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_nextBarButtonTapped
{
    [self _setupCompleteViewState];
    [FLYEndpointRequest uploadAudioFileServiceWithSuccessBlock:nil failureBlock:nil];
    FLYPrePostViewController *prePostVC = [FLYPrePostViewController new];
    prePostVC.audioDuration = self.audioLength;
    [self.navigationController pushViewController:prePostVC animated:YES];
}


- (void)_setupInitialViewState
{
    [self.levelsTimer invalidate];
    self.levelsTimer = nil;
    
    [[FLYAudioStateManager sharedInstance] removePlayer];
    
    [_trashButton removeFromSuperview];
    _trashButton = nil;
    
    [self.recordBottomBar removeFromSuperview];
    self.recordBottomBar = nil;
    _currentState = FLYRecordInitialState;
    
//    _outerCircleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kOuterCircleRadius, kOuterCircleRadius) radius:kOuterCircleRadius color:[UIColor whiteColor]];
//    [self.view addSubview:_outerCircleView];
//    
//    _innerCircleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kInnerCircleRadius, kInnerCircleRadius) radius:kInnerCircleRadius color:[UIColor flyBlue]];
//    [self.view insertSubview:_innerCircleView aboveSubview:_outerCircleView];
    
    [_userActionImageView removeFromSuperview];
    _userActionImageView = nil;
    
    _userActionImageView = [UIImageView new];
    _userActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_record"]];
    _userActionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_updateUserState)];
    [_userActionImageView addGestureRecognizer:_userActionTapGestureRecognizer];
    _userActionImageView.userInteractionEnabled = YES;
    [self.view addSubview:_userActionImageView];
    
    //reload right item
    [self loadRightBarButton];
    [self updateViewConstraints];
    [self.view layoutIfNeeded];
}

- (void)_setupRecordingViewState
{
    self.audioLength = 0;
    [self _setupRecordTimer];
    
    [_recordedTimeLabel removeFromSuperview];
    _recordedTimeLabel = [UILabel new];
    _recordedTimeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:21];
    _recordedTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _recordedTimeLabel.textColor = [UIColor flyColorRecordingTimer];
    _recordedTimeLabel.text = [NSString stringWithFormat:@":%d", kMaxRecordTime];
    
    [self.view addSubview:_recordedTimeLabel];
//    [self _addPulsingAnimation];
    [self updateViewConstraints];
    
    [[FLYAudioStateManager sharedInstance] startRecord];
    _audioPlayer = [FLYAudioStateManager sharedInstance].player;
    _audioController = [FLYAudioStateManager sharedInstance].audioController;
    
    [self _loadWaver];
    [self loadRightBarButton];
    
//    self.levelsTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateLevels:) userInfo:nil repeats:YES];
}

- (void)_loadWaver
{
    if(!self.waver) {
        self.waver = [[Waver alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 230, CGRectGetWidth(self.view.bounds), 100.0)];
        __weak Waver * weakWaver = self.waver;
        self.waver.waveColor = [UIColor flyColorFlyRecordingWave];
        @weakify(self);
        self.waver.waverLevelCallback = ^() {
            @strongify(self)
            Float32 inputAvg, inputPeak, outputAvg, outputPeak;
            [self.audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:&inputPeak];
            [self.audioController outputAveragePowerLevel:&outputAvg peakHoldLevel:&outputPeak];
            CGFloat normalizedValue = pow (10,  1.4* (inputAvg - 20) / 40);
            weakWaver.level = normalizedValue;
        };
        [self.view addSubview:self.waver];
    }
}

- (void)_setupCompleteViewState
{
    
    [self.recordedTimeLabel removeFromSuperview];
    [self.remainingTimeLabel removeFromSuperview];
    self.recordedTimeLabel = nil;
    self.remainingTimeLabel = nil;
//    [_pulsingHaloLayer removeFromSuperlayer];
    
    _innerCircleView.hidden = YES;
    [_outerCircleView setupLayerFillColor:[UIColor whiteColor] strokeColor:[UIColor flyLightGreen]];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
    
    [self.recordBottomBar removeFromSuperview];
    self.recordBottomBar = nil;
    self.recordBottomBar = [FLYRecordBottomBar new];
    [self.view addSubview:self.recordBottomBar];
    
    self.recordBottomBar.delegate = self;
    [self loadRightBarButton];
    [self updateViewConstraints];
}

- (void)_setupPlayingViewState
{
    [self.remainingTimeLabel removeFromSuperview];
    self.remainingTimeLabel = [UILabel new];
    self.remainingTimeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:21];
    self.remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.remainingTimeLabel.textColor = [UIColor flyColorRecordingTimer];
    self.remainingTimeLabel.text = [NSString stringWithFormat:@":%d", (int)self.audioLength];
    [self.view addSubview:self.remainingTimeLabel];
    
    [self _setupPlaybackTimer];
    
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_pause"]];
    [self updateViewConstraints];
}

- (void)_setupPauseViewState
{
    [[FLYAudioStateManager sharedInstance] pausePlayer];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
}

- (void)_setupResumeViewState
{
    [[FLYAudioStateManager sharedInstance] resumePlayer];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_pause"]];
}


#pragma mark - Recording state methods
- (void)_setupRecordTimer
{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateRecordingState) userInfo:nil repeats:YES];
}

- (void)_updateRecordingState
{
    if (self.audioLength >= kMaxRecordTime) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        [self _updateUserState];
        return;
    }
    
    self.audioLength++;
    _recordedTimeLabel.text = [NSString stringWithFormat:@":%ld", kMaxRecordTime - self.audioLength];
    [self.view setNeedsLayout];
}

#pragma mark - Playing state methods
- (void)_setupPlaybackTimer
{
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    self.remainingAudioLength = self.audioLength;
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updatePlayingState) userInfo:nil repeats:YES];
}

- (void)_updatePlayingState
{
    if (self.remainingAudioLength <= 0) {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
        //state will be updated in audio completion block
        return;
    }
    
    self.remainingAudioLength--;
    self.remainingTimeLabel.text = [NSString stringWithFormat:@":%ld", self.remainingAudioLength];
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
    
//    [self.outerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(kOuterCircleRadius * 2));
//        make.height.equalTo(@(kOuterCircleRadius * 2));
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(@(kOutCircleTopPadding));
//    }];
//    
//    
//    [self.innerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(kInnerCircleRadius * 2));
//        make.height.equalTo(@(kInnerCircleRadius * 2));
//        make.center.equalTo(self.outerCircleView);
//    }]; 
    
    [self.userActionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-50);
    }];
    
    if (_currentState == FLYRecordRecordingState) {
        if (self.remainingTimeLabel) {
            [self.recordedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.userActionImageView).with.offset(kTimeLabelTopPadding);
                make.centerX.equalTo(self.userActionImageView);
            }];
        }
    }
    
    if (_currentState == FLYRecordPlayingState) {
        if (self.remainingTimeLabel) {
            [self.remainingTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.userActionImageView).with.offset(kTimeLabelTopPadding);
                make.centerX.equalTo(self.userActionImageView);
            }];
        }
    }
    
    if (self.recordBottomBar) {
        [self.recordBottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.width.equalTo(@(CGRectGetWidth(self.view.bounds)));
            make.height.equalTo(@44);
        }];
    }
    
    if (self.waver) {
        [self.waver mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-50);
            make.trailing.equalTo(self.view);
            make.height.equalTo(@120);
        }];
    }
    
    [super updateViewConstraints];
}

- (void)_updateUserState
{
    [self.waver removeFromSuperview];
    self.waver = nil;
    
    [self _cleanupTimer];
    
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
            [[FLYAudioStateManager sharedInstance] stopRecord];
            [self _setupCompleteViewState];
            break;
        }
        case FLYRecordCompleteState:
        {
            _currentState = FLYRecordPlayingState;
            [[FLYAudioStateManager sharedInstance] playAudioWithCompletionBlock:_completionBlock];
            [self _setupPlayingViewState];
            break;
        }
        case FLYRecordPlayingState:
        {
            _currentState = FLYRecordPauseState;
            [self _setupPauseViewState];
            break;
        }
        case FLYRecordPauseState:
        {
            _currentState = FLYRecordPlayingState;
            [self _setupResumeViewState];
            break;
        }
        default:
            break;
    }

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    self.halo.position = self.userActionImageView.center;
    [FLYUtilities printAutolayoutTrace];
}

#pragma mark - FLYRecordBottomBarDelegate
- (void)trashButtonTapped:(UIButton *)button
{
    [self _setupInitialViewState];
}

- (void)nextButtonTapped:(UIButton *)button
{
    [self _nextBarButtonTapped];
}

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}

@end
