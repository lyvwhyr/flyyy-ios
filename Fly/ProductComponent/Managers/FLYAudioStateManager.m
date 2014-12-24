//
//  FLYAudioStateManager.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYAudioStateManager.h"
#import "AEAudioController.h"
#import "AERecorder.h"
#import "AEAudioFilePlayer.h"
#import "FLYFileManager.h"
#import "FLYPlayableItem.h"

@implementation FLYAudioStateManager

+ (instancetype)manager
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
    }
    return self;
}

- (void)startRecord
{
    if (_recorder) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
    } else {
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.aiff"];
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileAIFFType error:&error] ) {
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

- (void)playAudioURLStr:(NSString *)str WithCompletionBlock:(AudioPlayerCompleteblock)block
{
    if (_player) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
    }
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *path = [documentsFolders[0] stringByAppendingPathComponent:@"Recording.aiff"];
    
    if (str.length == 0) {
        //default
        str = @"http://freedownloads.last.fm/download/569264057/Get+Got.mp3";
    }
    
    NSURL *url = [NSURL URLWithString:str];
    //    NSString *path = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[url.pathComponents componentsJoinedByString:@"_"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
        return;
    }
    
    NSError *error = nil;
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


- (void)_initAudioController
{
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    [_audioController start:NULL];
    
    _recorder = [[AERecorder alloc] initWithAudioController:_audioController];
    [_audioController addOutputReceiver:_recorder];
    [_audioController addInputReceiver:_recorder];
}

@end
