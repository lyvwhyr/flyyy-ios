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
#import "UIView+Glow.h"
#import "Dialog.h"
#import "FLYUser.h"
#import "FLYEndpointRequest.h"
#import "FLYReply.h"
#import "JGProgressHUD.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150
#define kOutCircleTopPadding 80
#define kFilterModalHeight 80
#define kMaxRetry 3
#define kTimeLabelTopPadding 30
#define kMinimalRecordingLength 5

@interface FLYRecordViewController ()<FLYRecordBottomBarDelegate, JGProgressHUDDelegate>

@property (nonatomic) UIBarButtonItem *rightNavigationButton;

@property (nonatomic) FLYCircleView *innerCircleView;
@property (nonatomic) FLYCircleView *outerCircleView;
@property (nonatomic) UIImageView *userActionImageView;
@property (nonatomic) UIImageView *glowView;
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

//Post reply progress hud
@property (nonatomic) JGProgressHUD *progressHUD;


@property (nonatomic, copy) AudioPlayerCompleteblock completionBlock;

@property (nonatomic, readonly) UITapGestureRecognizer *userActionTapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *deleteRecordingTapGestureRecognizer;

@property (nonatomic) NSInteger audioLength;
@property (nonatomic) NSInteger remainingAudioLength;
@property (nonatomic) NSTimer *levelsTimer;

@property (nonatomic) NSString *mediaId;
@property (nonatomic) NSString *replyMediaId;
@property (nonatomic) NSInteger retryCount;

@end

@implementation FLYRecordViewController

#define kMaxRecordTime          60

- (instancetype)initWithRecordType:(FLYRecordingType)recordingType
{
    if (self = [super init]) {
        _recordingType = recordingType;
        
    }
    return self;
}


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
    [self _cleanupData];
}

- (void)_initVoiceRecording
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[FLYAudioStateManager sharedInstance] initRecordingAudioController];
    });
    
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


#pragma mark - clean up 

- (void)_cleanupData
{
    [self _cleanupTimer];
    [self.waver removeFromSuperview];
    self.waver.waverLevelCallback = nil;
    self.waver = nil;
}

- (void) _cleanupTimer
{
    [self.recordedTimeLabel removeFromSuperview];
    self.recordedTimeLabel = nil;
    
    [self.remainingTimeLabel removeFromSuperview];
    self.remainingTimeLabel = nil;
    
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
        FLYBarButtonItem *barButtonItem;
        if (self.recordingType == RecordingForTopic) {
            barButtonItem = [FLYPostRecordingNextBarButtonItem barButtonItem:NO];
        } else {
            barButtonItem = [FLYPostRecordingPostBarButtonItem barButtonItem:NO];
        }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kUsePlaybackOnlyNotification object:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_nextBarButtonTapped
{
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    if (self.recordingType == RecordingForTopic) {
        [FLYEndpointRequest uploadAudioFileServiceWithUserId:userId successBlock:nil failureBlock:nil];
        [self _setupCompleteViewState];
        FLYPrePostViewController *prePostVC = [FLYPrePostViewController new];
        prePostVC.audioDuration = self.audioLength;
        [self.navigationController pushViewController:prePostVC animated:YES];
    } else {
        if (self.replyMediaId) {
            NSDictionary *dict = @{@"topic_id":self.topicId,
                                   @"media_id":self.replyMediaId,
                                   @"audio_duration":@(self.audioLength)};
            NSMutableDictionary *mutableDict = [dict mutableCopy];
            if (self.parentReplyId) {
                [mutableDict setObject:self.parentReplyId forKey:@"parent_reply_id"];
            }
            [self _postReplyServiceWithParams:mutableDict];
        } else {
            self.progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            self.progressHUD.delegate = self;
            self.progressHUD.textLabel.text = @"Posting...";
            [self.progressHUD showInView:self.view];
            
            @weakify(self)
            [FLYEndpointRequest uploadAudioFileServiceWithUserId:userId successBlock:^(NSString *mediaId) {
                @strongify(self)
                self.replyMediaId = mediaId;
                NSDictionary *dict = @{@"topic_id":self.topicId,
                                       @"media_id":self.replyMediaId,
                                       @"audio_duration":@(self.audioLength)};
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                if (self.parentReplyId) {
                    [mutableDict setObject:self.parentReplyId forKey:@"parent_reply_id"];
                }
                [self _postReplyServiceWithParams:mutableDict];
            } failureBlock:^{
                [self.progressHUD dismiss];
                [Dialog simpleToast:LOC(@"FLYGenericError")];
            }];
        }
    }
}

- (void)_postReplyServiceWithParams:(NSDictionary *)dict
{
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    NSString *baseURL =  [NSString stringWithFormat:@"replies?user_id=%@", userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseURL parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.progressHUD dismiss];
        
        FLYReply *reply = [[FLYReply alloc] initWithDictionary:responseObject];
        NSDictionary *dict = @{kNewReplyKey:reply};
        [Dialog simpleToast:@"Posted"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewReplyReceivedNotification object:self userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUsePlaybackOnlyNotification object:self];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.progressHUD dismiss];
        [Dialog simpleToast:LOC(@"FLYGenericError")];
        UALog(@"Post error %@", error);
    }];
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
    
    [_userActionImageView removeFromSuperview];
    _userActionImageView = nil;
    
    _userActionImageView = [UIImageView new];
    _userActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_bg"]];
    _userActionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_updateUserState)];
    [_userActionImageView addGestureRecognizer:_userActionTapGestureRecognizer];
    _userActionImageView.userInteractionEnabled = YES;
    [self.view addSubview:_userActionImageView];
    
    
    [self.glowView removeFromSuperview];
    self.glowView  = nil;
    
    self.glowView  = [UIImageView new];
    self.glowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.glowView  setImage:[UIImage imageNamed:@"icon_microphone"]];
    [self.view addSubview:self.glowView ];
    
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
    
    [self updateViewConstraints];
    
    [[FLYAudioStateManager sharedInstance] startRecord];
    
    [self _loadWaver];
    [self loadRightBarButton];
    [self.glowView startGlowingWithColor:[UIColor whiteColor] intensity:1];
}

- (void)_loadWaver
{
    if(!self.waver) {
        self.waver = [[Waver alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 230, CGRectGetWidth(self.view.bounds), 100.0)];
        self.waver.waveColor = [UIColor flyColorFlyRecordingWave];
        @weakify(self)
        self.waver.waverLevelCallback = ^() {
            @strongify(self)
            Float32 inputAvg, inputPeak, outputAvg, outputPeak;
            [[FLYAudioStateManager sharedInstance].audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:&inputPeak];
            [[FLYAudioStateManager sharedInstance].audioController outputAveragePowerLevel:&outputAvg peakHoldLevel:&outputPeak];
            CGFloat normalizedValue = pow (10,  1.4* (inputAvg - 10) / 40);
            self.waver.level = normalizedValue;
        };
        [self.view addSubview:self.waver];
    }
}

- (void)_setupCompleteViewState
{
    self.remainingAudioLength = self.audioLength;
    [self.glowView stopGlowing];
    [self.glowView removeFromSuperview];
    self.glowView = nil;
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
    [self _addPlaybackTimer];
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
    [self _addPlaybackTimer];
    [self updateViewConstraints];
}

- (void)_addPlaybackTimer
{
    [self.remainingTimeLabel removeFromSuperview];
    self.remainingTimeLabel = [UILabel new];
    self.remainingTimeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:21];
    self.remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.remainingTimeLabel.textColor = [UIColor flyColorRecordingTimer];
    self.remainingTimeLabel.text = [NSString stringWithFormat:@":%d", (int)self.remainingAudioLength];
    [self.view addSubview:self.remainingTimeLabel];
    [self _setupPlaybackTimer];
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
    [self.userActionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-50);
    }];
    
    if (self.glowView) {
        [self.glowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.userActionImageView);
        }];
    }
    
    if (_currentState == FLYRecordRecordingState) {
        if (self.recordedTimeLabel) {
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
            if (self.recordingType == RecordingForTopic && self.audioLength <= kMinimalRecordingLength) {
                [Dialog simpleToast:[NSString stringWithFormat:LOC(@"FLYLessThanMinimalRecordingLength"), kMinimalRecordingLength] withDuration:1.0f];
                [self _setupInitialViewState];
                return;
            }
            
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
    [FLYUtilities printAutolayoutTrace];
}

#pragma mark - FLYRecordBottomBarDelegate
- (void)trashButtonTapped:(UIButton *)button
{
    [self _cleanupTimer];
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
