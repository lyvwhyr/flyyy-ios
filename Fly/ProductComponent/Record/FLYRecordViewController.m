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
#import "FLYRecordVoiceFilterViewController.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150
#define kOutCircleTopPadding 80
#define kFilterModalHeight 80


@interface FLYRecordViewController ()<FLYUniversalViewControllerDelegate>

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
@property (nonatomic) DKCircleButton *voiceFilterButton;
@property (nonatomic) FLYRecordVoiceFilterViewController *filterModalViewController;

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
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(_backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    UILabel *rightBarLabel = [UILabel new];
    rightBarLabel.text = @"Next";
    rightBarLabel.font = [UIFont systemFontOfSize:22];
    rightBarLabel.textColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:<#(UIView *)#>
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(_nextBarButtonTapped)];
}

-(void)loadRightBarButton
{
    FLYPostRecordingNextBarButtonItem *barButtonItem = [FLYPostRecordingNextBarButtonItem barButtonItem:NO];
    __weak typeof(self) weakSelf = self;
    barButtonItem.actionBlock = ^(FLYBarButtonItem *item) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _nextBarButtonTapped];
    };
    self.navigationItem.rightBarButtonItem = barButtonItem;
}
                                              

#pragma mark - navigation bar actions

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

#pragma mark - recording complete actions
- (void)_voiceFilterButtonTapped
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenBounds);
    CGFloat screenHeight = CGRectGetHeight(screenBounds);
    if (self.childViewControllers.count == 0) {
        self.filterModalViewController = [FLYRecordVoiceFilterViewController new];
        self.filterModalViewController.delegate = self;
        [self addChildViewController:self.filterModalViewController];
        self.filterModalViewController.view.frame = CGRectMake(0, screenHeight, screenWidth, kFilterModalHeight);
        self.filterModalViewController.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.filterModalViewController.view];
        [UIView animateWithDuration:0.2 animations:^{
            self.filterModalViewController.view.frame = CGRectMake(0, screenHeight - kFilterModalHeight, screenWidth, kFilterModalHeight);;
        } completion:^(BOOL finished) {
            [self.filterModalViewController didMoveToParentViewController:self];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.filterModalViewController.view.frame = CGRectMake(0, screenHeight, screenWidth, kFilterModalHeight);
        } completion:^(BOOL finished) {
            [self.filterModalViewController.view removeFromSuperview];
            [self.filterModalViewController removeFromParentViewController];
            self.filterModalViewController = nil;
        }];
    }
}

#pragma mark - FLYRecordVoiceFilterViewController
- (void)normalFilterButtonTapped:(id)button
{
    UALog(@"normal");
    [[FLYAudioStateManager sharedInstance] removeFilter];
}

- (void)adjustPitchFilterButtonTapped:(id)button
{
    UALog(@"adjust pitch");
    [[FLYAudioStateManager sharedInstance] applyFilter];
}


- (void)_setupInitialViewState
{
    [self.levelsTimer invalidate];
    self.levelsTimer = nil;
    
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
    
    [[FLYAudioStateManager sharedInstance] startRecord];
    _audioPlayer = [FLYAudioStateManager sharedInstance].player;
    _audioController = [FLYAudioStateManager sharedInstance].audioController;
    
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
    
    

    _voiceFilterButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    
    _voiceFilterButton.center = CGPointMake(60, 420);
    _voiceFilterButton.titleLabel.font = [UIFont systemFontOfSize:22];
    
    [_voiceFilterButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _voiceFilterButton.animateTap = NO;
    [_voiceFilterButton setTitle:NSLocalizedString(@"Adjust Voice", nil) forState:UIControlStateNormal];
    [_voiceFilterButton addTarget:self action:@selector(_voiceFilterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_voiceFilterButton];
    
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
        make.centerX.equalTo(self.view);
        make.top.equalTo(@(kOutCircleTopPadding));
    }];
    
    
    [self.innerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kInnerCircleRadius * 2));
        make.height.equalTo(@(kInnerCircleRadius * 2));
        make.center.equalTo(self.outerCircleView);
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
    
//    if (_voiceFilterButton) {
//        [_voiceFilterButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.outerCircleView.mas_bottom).offset(30);
//            make.left.equalTo(self.view.mas_leading).offset(20);
//        }];
//    }
    
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
            [[FLYAudioStateManager sharedInstance] stopRecord];
            [self _setupCompleteViewState];
            break;
        }
        case FLYRecordCompleteState:
        {
            _currentState = FLYRecordPauseState;
//            [[FLYAudioStateManager sharedInstance] playAudioURLStr:nil withCompletionBlock:_completionBlock];
            [[FLYAudioStateManager sharedInstance] playAudioWithCompletionBlock:_completionBlock];
            [self _setupPauseViewState];
            break;
        }
        case FLYRecordPauseState:
        {
            _currentState = FLYRecordCompleteState;
            [[FLYAudioStateManager sharedInstance] playAudioWithCompletionBlock:_completionBlock];
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
