//
//  FLYAudioStateManager.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//
#import <AVFoundation/AVAudioSession.h>
#import "FLYAudioStateManager.h"
#import "AEAudioController.h"
#import "AERecorder.h"
#import "AEAudioFilePlayer.h"
#import "FLYFileManager.h"
#import "FLYPlayableItem.h"
#import "AEAudioFileWriter.h"
#import "FLYFileManager.h"

#define kRecordingAudioFileName  "kRecordingAudioFileName.m4a"


@interface FLYAudioStateManager()

@property (nonatomic) BOOL isRecordAudioMode;
@property (nonatomic) BOOL isApplyingFilter;
@property (nonatomic) AEAudioUnitFilter *pitch;

@end


@implementation FLYAudioStateManager

+ (instancetype)sharedInstance
{
    static FLYAudioStateManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    if (self = [super init]) {
        [self _initAudioController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)startRecord
{
    [self _initRecordAudioController];
    
    NSString *path = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:@"kRecordingAudioFileName.m4a"];
    NSError *error = nil;
    if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileM4AType error:&error] ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        self.recorder = nil;
        return;
    }
    [_audioController addOutputReceiver:_recorder];
    [_audioController addInputReceiver:_recorder];
}

- (void)stopRecord
{
    if (_recorder) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
    }
    
}

- (void)pausePlayer
{
    self.currentPlayItem.playState = FLYPlayStatePaused;
    _player.channelIsPlaying = NO;

}

- (void)resumePlayer
{
    self.currentPlayItem.playState = FLYPlayStatePlaying;
    _player.channelIsPlaying = YES;
}

- (void)playAudioWithCompletionBlock:(AudioPlayerCompleteblock)block
{
    NSError *error = nil;
    if (_player) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
    }
    
    NSString *str = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:@"kRecordingAudioFileName.m4a"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
        return;
    }
    
    self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:str] audioController:_audioController error:&error];
    self.player.loop = NO;
    
    if ( !_player ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    NSLog(@"audio duration before %f", _player.duration);
    
    _player.removeUponFinish = YES;
    _player.completionBlock = [block copy];
    [_audioController addChannels:@[_player]];
    NSLog(@"audio duration after %f", _player.duration);
}

- (void)applyFilter
{
    if (self.isApplyingFilter) {
        return;
    }
    self.isApplyingFilter = YES;
    NSError *error = NULL;
    _pitch = [[AEAudioUnitFilter alloc]
                                initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                                             kAudioUnitType_FormatConverter,
                                                                                             kAudioUnitSubType_Varispeed)
                                audioController:_audioController
                                error:&error];
    AudioUnitSetParameter(_pitch.audioUnit, kAudioUnitScope_Global, 0, kVarispeedParam_PlaybackRate, 1.15, 0);
    [_audioController addFilter:_pitch];
    [self _writeAudioToFile];
}

- (void)removeFilter
{
    if (self.isApplyingFilter) {
        self.isApplyingFilter = NO;
        [_audioController removeFilter:_pitch];
        _pitch = nil;
        [self _writeAudioToFile];
    }
}

- (void)_writeAudioToFile
{
    
    AEAudioFileWriter *audioFileWriter =[[AEAudioFileWriter alloc] initWithAudioDescription:_audioController.audioDescription];
    
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"kRecordingAudioFileName.m4a"];
    NSError *error = nil;
//    [audioFileWriter beginWritingToFileAtPath:path fileType:kAudioFileM4AType error:nil];
    
    
    
    UInt32 numberOfSamples = 4096;
    
    AudioBufferList *list = AEAllocateAndInitAudioBufferList(_audioController.audioDescription, numberOfSamples);
    
    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    
    AEAudioControllerRenderMainOutput(_audioController, timeStamp, numberOfSamples, list);
    OSStatus status = AEAudioFileWriterAddAudioSynchronously(audioFileWriter, list, numberOfSamples);
    if (status != 0) {
        NSLog(@"ERROR: %d", (int)status);
    }
}


- (void)playAudioURLStr:(NSString *)str withCompletionBlock:(AudioPlayerCompleteblock)block
{
    if (_player) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
    }
    
    if (!str) {
        UALog(@"Audio file string is empty");
    }
    
    NSError *error = NULL;
    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
//        block();
        return;
    }
    
    self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:str] audioController:_audioController error:&error];
    self.player.loop = NO;
    
    if ( !_player ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    NSLog(@"audio duration before %f", _player.duration);
    
    _player.removeUponFinish = YES;
//    block();
    _player.completionBlock = [block copy];
    [_audioController addChannels:@[_player]];
    NSLog(@"audio duration after %f", _player.duration);
}

- (void)removePlayer
{
    [_audioController removeChannels:@[_player]];
    self.player = nil;
}


- (void)_initAudioController
{
    if (_audioController) {
        [_audioController stop];
        _audioController = nil;
    }
    
    self.isRecordAudioMode = NO;
    
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:NO];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    _audioController.allowMixingWithOtherApps = NO;
    _audioController.audioSessionCategory = AVAudioSessionCategoryPlayback;
    [_audioController start:NULL];
}

- (void)_initRecordAudioController
{
    if (self.isRecordAudioMode && _audioController) {
        _recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        return;
    }
    
    if (_audioController) {
        [_audioController stop];
        _audioController = nil;
    }
    self.isRecordAudioMode = YES;
    
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    _audioController.allowMixingWithOtherApps = NO;
    _audioController.audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
    [_audioController start:NULL];
    
    _recorder = [[AERecorder alloc] initWithAudioController:_audioController];
}



- (void)_appWillEnterForeground:(NSNotification *)notification
{
    if (!_audioController) {
        [self _initAudioController];
        [_audioController start:nil];
    }
}

- (void)_appDidEnterBackground:(NSNotification *)notification
{
    if (_audioController.audioInputAvailable) {
        [_audioController removeInputReceiver:_recorder];
        [_audioController removeOutputReceiver:_recorder];
        
        [_audioController stop];
         _audioController = nil;
    }
}

@end
