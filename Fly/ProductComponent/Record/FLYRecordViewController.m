//
//  FLYRecordViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FLYRecordViewController.h"
#import "FLYCircleView.h"
#import "UIColor+FLYAddition.h"
#import "SVPulsingAnnotationView.h"
#import "MultiplePulsingHaloLayer.h"
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
#import "AFSoundRecord.h"
#import "FLYFileManager.h"
#import "STKAudioPlayer.h"
#import "FLYVoiceFilterManager.h"
#import "FLYVoiceEffectView.h"
#import "SDiPhoneVersion.h"
#import "FLYTopic.h"
#import "FLYMediaService.h"
#import "FLYGroup.h"
#import "FLYAudioItem.h"
#import "FLYDashTextView.h"
#import "UIFont+FLYAddition.h"

#define kInnerCircleRadius 100
#define kOuterCircleRadius 150
#define kOutCircleTopPadding 80
#define kFilterModalHeight 80
#define kMaxRetry 3
#define kTimeLabelTopPadding 30
#define kMaxRecordTime 60
#define kOnboardingMaxWidth 245
#define kOnBoardingArrowSpacing 2

@interface FLYRecordViewController ()<FLYRecordBottomBarDelegate, JGProgressHUDDelegate, STKAudioPlayerDelegate, FLYVoiceEffectViewDelegate>

@property (nonatomic) UIBarButtonItem *rightNavigationButton;

@property (nonatomic) UIImageView *userActionImageView;
@property (nonatomic) UIImageView *glowView;
@property (nonatomic) UILabel *recordedTimeLabel;
@property (nonatomic) UILabel *remainingTimeLabel;
@property (nonatomic) SVPulsingAnnotationView *pulsingView;

//Record complete state
@property (nonatomic) UIButton *trashButton;
@property (nonatomic) FLYRecordBottomBar *recordBottomBar;
@property (nonatomic) Waver *waver;
@property (nonatomic) FLYVoiceEffectView *filterView;

@property (nonatomic) FLYRecordState currentState;
@property (nonatomic) NSTimer *recordTimer;
@property (nonatomic) NSTimer *playbackTimer;

//Post reply progress hud
@property (nonatomic) JGProgressHUD *progressHUD;

@property (nonatomic) STKAudioPlayer *audioPlayer;

//Recorder
@property (nonatomic) AFSoundRecord *recorder;

// Voice filter
@property (nonatomic) FLYVoiceFilterEffect filterEffect;
@property (nonatomic) UIActivityIndicatorView *loadingView;

// Onboarding
@property (nonatomic) FLYDashTextView *onboardingTextView;
@property (nonatomic) UIImageView *dashTextViewArrow;

@property (nonatomic, readonly) UITapGestureRecognizer *userActionTapGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *deleteRecordingTapGestureRecognizer;

@property (nonatomic) NSInteger audioLength;
@property (nonatomic) NSInteger remainingAudioLength;
@property (nonatomic) NSTimer *levelsTimer;

@property (nonatomic) NSString *mediaId;
@property (nonatomic) NSString *replyMediaId;
@property (nonatomic) NSInteger retryCount;

@property (nonatomic) NSMutableArray *alreadyProcessedEffects;

@end

@implementation FLYRecordViewController

- (instancetype)initWithRecordType:(FLYRecordingType)recordingType
{
    if (self = [super init]) {
        _recordingType = recordingType;
        _filterEffect = FLYVoiceEffectMe;
        
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        _audioPlayer.meteringEnabled = YES;
        _audioPlayer.volume = 1;
        _audioPlayer.delegate = self;
        
        _alreadyProcessedEffects = [NSMutableArray new];
        [_alreadyProcessedEffects addObject:@(FLYVoiceEffectMe)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_vioceFilterApplied:) name:kVoiceFilterApplied object:nil];
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
    
    [self _setupInitialViewState];
    [self updateViewConstraints];
    
    if (self.recordingType == RecordingForTopic) {
        [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"recording_page" component:@"topic" element:nil action:@"impression"];
    } else {
        [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"recording_page" component:@"reply" element:nil action:@"impression"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.audioPlayer stop];
}

- (void)dealloc
{
    NSLog(@"RecordViewController dealloc called");
    [self _cleanupData];
}

- (UIActivityIndicatorView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}

#pragma mark - clean up 

- (void)_cleanupData
{
    [self _cleanupTimer];
    [self.waver removeFromSuperview];
    self.waver = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_nextBarButtonTapped
{
    if (![self _isAlreadyProcessed:self.filterEffect]) {
        [Dialog simpleToast:LOC(@"FLYRecordingStillProcessing")];
        return;
    }
    
    self.currentState = FLYRecordReadyToPlay;
    [self _updateUserState];    
    self.currentState = FLYRecordCompleteState;

    if (self.recordingType == RecordingForTopic) {
        FLYUploadToS3SuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
            
        };
        
        FLYUploadToS3ErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            
        };
        [FLYMediaService getSignedUrlAndUploadWithSuccessBlock:successBlock errorBlock:errorBlock];
        
        FLYPrePostViewController *prePostVC = [FLYPrePostViewController new];
        prePostVC.audioDuration = self.audioLength;
        if (self.defaultGroup) {
            prePostVC.defaultGroup = self.defaultGroup;
        }
        [self.navigationController pushViewController:prePostVC animated:YES];
    } else {
        [self _disableUserInteractionsOnAnimation];
        [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:@"reply" element:@"post_button" action:@"click"];
        
        if (self.replyMediaId) {
            NSDictionary *dict = @{@"topic_id":self.topic.topicId,
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
            FLYUploadToS3SuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
                @strongify(self)
                self.replyMediaId = [FLYAppStateManager sharedInstance].mediaId;
                NSDictionary *dict = @{@"topic_id":self.topic.topicId,
                                       @"media_id":self.replyMediaId,
                                       @"audio_duration":@(self.audioLength)};
                NSMutableDictionary *mutableDict = [dict mutableCopy];
                if (self.parentReplyId) {
                    [mutableDict setObject:self.parentReplyId forKey:@"parent_reply_id"];
                }
                [self _postReplyServiceWithParams:mutableDict];
            };
            
            FLYUploadToS3ErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
                [self _enableUserInteractionsAfterAnimation];
                
                [self.progressHUD dismiss];
                [Dialog simpleToast:LOC(@"FLYGenericError")];
            };
            [FLYMediaService getSignedUrlAndUploadWithSuccessBlock:successBlock errorBlock:errorBlock];
        }
    }
}

- (void)_disableUserInteractionsOnAnimation
{
    [[self.view subviews] makeObjectsPerformSelector:@selector(setUserInteractionEnabled:) withObject:@(NO)];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)_enableUserInteractionsAfterAnimation
{
    [[self.view subviews] makeObjectsPerformSelector:@selector(setUserInteractionEnabled:) withObject:@(YES)];
    [self loadRightBarButton];
}

- (void)_postReplyServiceWithParams:(NSDictionary *)dict
{
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    NSString *baseURL =  [NSString stringWithFormat:@"replies?user_id=%@", userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseURL parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (self.progressHUD && self.progressHUD.visible) {
            [self.progressHUD dismiss];
        }
        
        FLYReply *reply = [[FLYReply alloc] initWithDictionary:responseObject];
        NSDictionary *dict = @{kNewReplyKey:reply, kTopicOfNewReplyKey:self.topic};
        [self.topic incrementReplyCount:dict];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [self _enableUserInteractionsAfterAnimation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _enableUserInteractionsAfterAnimation];
        
        [self.progressHUD dismiss];
        [Dialog simpleToast:LOC(@"FLYGenericError")];
        UALog(@"Post error %@", error);
    }];
}


- (void)_setupInitialViewState
{
    [self.levelsTimer invalidate];
    self.levelsTimer = nil;
    
    [self.audioPlayer stop];
    
    [_trashButton removeFromSuperview];
    _trashButton = nil;
    
    [self.alreadyProcessedEffects removeAllObjects];
    
    [self.recordBottomBar removeFromSuperview];
    self.recordBottomBar = nil;
    _currentState = FLYRecordInitialState;
    
    [self.filterView removeFromSuperview];
    self.filterView = nil;
    
    [_userActionImageView removeFromSuperview];
    _userActionImageView = nil;
    
    _userActionImageView = [UIImageView new];
    _userActionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_bg"]];
    _userActionTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_updateUserState)];
    [_userActionImageView addGestureRecognizer:_userActionTapGestureRecognizer];
    _userActionImageView.userInteractionEnabled = YES;
    [self.view addSubview:_userActionImageView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasSeenRecordingOnboarding = [[defaults objectForKey:kRecordingOnboardingKey] boolValue];
    if(!hasSeenRecordingOnboarding) {
        [self _setupOnboardingView];
    }
    
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
    
    NSString *path = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:kRecordingAudioFileName];
    [FLYAppStateManager sharedInstance].recordingFilePath = path;
    [FLYAppStateManager sharedInstance].recordingFilePathSelected = path;
    _recorder = [[AFSoundRecord alloc] initWithFilePath:path];
    [_recorder startRecording];
    
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
            [self.recorder.recorder updateMeters];
            CGFloat normalizedValue = pow (10, [self.recorder.recorder averagePowerForChannel:0] / 40);
            self.waver.level = normalizedValue;
        };
        [self.view addSubview:self.waver];
    }
}

- (void)_setupCompleteViewState
{
    [self.recorder saveRecording];
    
    self.remainingAudioLength = self.audioLength;
    [self.glowView stopGlowing];
    [self.glowView removeFromSuperview];
    self.glowView = nil;
    [self.recordedTimeLabel removeFromSuperview];
    [self.remainingTimeLabel removeFromSuperview];
    self.recordedTimeLabel = nil;
    self.remainingTimeLabel = nil;
    
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
    
    [self.recordBottomBar removeFromSuperview];
    self.recordBottomBar = nil;
    self.recordBottomBar = [FLYRecordBottomBar new];
    [self.view addSubview:self.recordBottomBar];
    
    if (!self.filterView) {
        [self.filterView removeFromSuperview];
        self.filterView = nil;
        self.filterView = [FLYVoiceEffectView new];
        [self.view addSubview:self.filterView];
        self.filterView.delegate = self;
    }
    
    self.recordBottomBar.delegate = self;
    [self loadRightBarButton];
    [self updateViewConstraints];
}

- (void)_setupReadyToPlay
{
    [self.audioPlayer stop];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
    self.remainingAudioLength = self.audioLength;
}

- (void)_setupPlayingViewState
{
    [self _addPlaybackTimer];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_pause"]];
    [self updateViewConstraints];
}

- (void)_setupPauseViewState
{
    [self.audioPlayer pause];
    [_userActionImageView setImage:[UIImage imageNamed:@"icon_record_play"]];
}

- (void)_setupResumeViewState
{
    [self.audioPlayer resume];
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

#pragma mark - Onboarding view
- (void)_setupOnboardingView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(YES) forKey:kRecordingOnboardingKey];
    [defaults synchronize];
    
    UIFont *font = [UIFont flyFontWithSize:18];
    UIFont *highlightFont = [UIFont fontWithName:@"Avenir-black" size:18];
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
    _onboardingTextView = [[FLYDashTextView alloc] initWithText:LOC(@"FLYOnboardingFirstTimeHint") font:font color:[UIColor flyBlue] hightlightItems:@[LOC(@"FLYOnboardingFirstTimeHintHighlight")] highlightFont:highlightFont edgeInsets:insets dashColor:FLYDashTextBlue maxLabelWidth:kOnboardingMaxWidth];
    [self.view addSubview:_onboardingTextView];
    
    _dashTextViewArrow = [UIImageView new];
    _dashTextViewArrow.image = [UIImage imageNamed:@"icon_up_arrow"];
    [self.view addSubview:_dashTextViewArrow];
}

- (void)_hideOnboardingView
{
    [self.onboardingTextView removeFromSuperview];
    _onboardingTextView = nil;
    
    [self.dashTextViewArrow removeFromSuperview];
    _dashTextViewArrow = nil;
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
    _recordedTimeLabel.text = [NSString stringWithFormat:@":%d", (int)(kMaxRecordTime - self.audioLength)];
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
    self.remainingTimeLabel.text = [NSString stringWithFormat:@":%ld", (long)self.remainingAudioLength];
    [self.view setNeedsLayout];
}

-(void)updateViewConstraints
{
    CGFloat userActionOffset = -60;
    CGFloat filterViewTopOffset = 20;
    
    if ([SDiPhoneVersion deviceVersion] == iPhone6Plus) {
        userActionOffset = -100;
        filterViewTopOffset = 70;
    }
    
    [self.userActionImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(userActionOffset);
    }];
    
    if (self.glowView) {
        [self.glowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.userActionImageView);
        }];
    }
    
    if (self.onboardingTextView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
        CGFloat textHeight = [FLYDashTextView geLabelHeightWithText:LOC(@"FLYOnboardingFirstTimeHint") font:[UIFont flyFontWithSize:18] hightlightItems:@[LOC(@"FLYOnboardingFirstTimeHintHighlight")] highlightFont:[UIFont fontWithName:@"Avenir-black" size:18] maxLabelWidth:kOnboardingMaxWidth];
        [self.onboardingTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userActionImageView.mas_bottom).offset(50);
            make.leading.equalTo(self.view).offset(20);
            make.trailing.equalTo(self.view).offset(-20);
            // add extra 2 points to give text enough height
            make.height.equalTo(@(textHeight + insets.top * 2));
        }];
        
        [self.dashTextViewArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userActionImageView.mas_bottom).offset(kOnBoardingArrowSpacing);
            make.bottom.equalTo(self.onboardingTextView.mas_top).offset(-kOnBoardingArrowSpacing);
            make.centerX.equalTo(self.onboardingTextView);
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
        
        if (self.filterView) {
            [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.userActionImageView.mas_bottom).offset(filterViewTopOffset);
                make.leading.equalTo(self.view);
                make.width.equalTo(@(CGRectGetWidth(self.view.bounds)));
                make.height.equalTo(@(120));
            }];
            
            if (_loadingView) {
                [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.userActionImageView);
                    make.centerY.equalTo(self.userActionImageView);
                }];
            }
        }
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
    
    [self _hideOnboardingView];
    
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
            [self _setupCompleteViewState];
            break;
        }
        case FLYRecordCompleteState:
        {
            self.currentState = FLYRecordPlayingState;
            
            NSURL *url = [NSURL fileURLWithPath:[FLYAppStateManager sharedInstance].recordingFilePathSelected];
            STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
            [self.audioPlayer setDataSource:dataSource withQueueItemId:[[FLYAudioItem alloc] initWithUrl:url andCount:0 indexPath:nil itemType:FLYPlayableItemRecording playState:FLYPlayStateNotSet audioDuration:self.audioLength]];
            
            
            [self _setupPlayingViewState];
            break;
        }
        case FLYRecordPlayingState:
        {
            [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"recording_page" component:nil element:@"replay_button" action:@"click"];
            
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
        case FLYRecordReadyToPlay:
        {
            [self _setupReadyToPlay];
        }
        default:
            break;
    }

}

#pragma mark - STKAudioPlayerDelegate

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(FLYAudioItem *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if (queueItemId.itemType != FLYPlayableItemRecording || stopReason == STKAudioPlayerStopReasonUserAction) {
        return;
    }
    
    self.currentState = FLYRecordRecordingState;
    [self _updateUserState];
}


-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}


#pragma mark - FLYVoiceEffectViewDelegate

- (void)voiceEffectTapped:(FLYVoiceFilterEffect)effect
{
    self.filterEffect = effect;
    
    // set to ready to play state
    self.currentState = FLYRecordReadyToPlay;
    [self _updateUserState];
    self.currentState = FLYRecordCompleteState;

    if (effect == FLYVoiceEffectMe) {
        [FLYAppStateManager sharedInstance].recordingFilePathSelected = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:kRecordingAudioFileName];
    } else if ([self _isAlreadyProcessed:effect]) {
        [FLYAppStateManager sharedInstance].recordingFilePathSelected = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d%@", kRecordingAudioFileNameAfterFilter, (int)effect, kAudioFileExt]];
    } else {
        FLYVoiceFilterManager *filterManager = [[FLYVoiceFilterManager alloc] initWithEffect:effect];
        //Loading view
        [self.view addSubview:self.loadingView];
        [self updateViewConstraints];
        self.userActionImageView.userInteractionEnabled = NO;
        [self.view bringSubviewToFront:self.loadingView];
        [self.loadingView startAnimating];
        
        [FLYAppStateManager sharedInstance].recordingFilePathSelected = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d%@", kRecordingAudioFileNameAfterFilter, (int)effect, kAudioFileExt]];
        [filterManager applyFiltering:effect];
    }
}

- (BOOL)_isAlreadyProcessed:(NSInteger)value
{
    if (value == FLYVoiceEffectMe) {
        return YES;
    }
    
    for (int i = 0; i < [self.alreadyProcessedEffects count]; i++) {
        if (value == [self.alreadyProcessedEffects[i] integerValue]) {
            return YES;
        }
    }
    return NO;
}

# pragma mark - Notificaiton

- (void)_vioceFilterApplied:(NSNotification *)notification
{
    FLYVoiceFilterEffect effect = [[notification.userInfo objectForKey:@"filter_effect"] integerValue];
    [self.alreadyProcessedEffects addObject:@(effect)];
    
    self.userActionImageView.userInteractionEnabled = YES;
    [_loadingView stopAnimating];
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

#pragma mark - FLYRecordBottomBarDelegate
- (void)trashButtonTapped:(UIButton *)button
{
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"recording_page" component:nil element:@"trash_button" action:@"click"];
    
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
