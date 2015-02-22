//
//  AFSoundRecord.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 10/02/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundRecord.h"

@interface AFSoundRecord ()

@end

@implementation AFSoundRecord

- (id)initWithFilePath:(NSString *)filePath {
    
    if (self == [super init]) {
        

        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

        NSError *err = nil;
        if([_recorder isRecording])
        {
            [_recorder stop];
            _recorder = nil;
        }
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSetting error:nil];
        
        if(err)
            NSLog(@"ERROR : %@", err);
        
        _recorder.meteringEnabled = YES;
        
        
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryRecord error:nil];
//        [session setActive:YES error:nil];
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [_recorder prepareToRecord];
        [_recorder setMeteringEnabled:YES];
    }
    return self;
}

-(void)startRecording {
    BOOL status = [_recorder record];
    if(!status)
        NSLog(@"Failed");
}

-(void)saveRecording {
    
    [_recorder stop];
}

-(void)cancelCurrentRecording {
    
    [_recorder stop];
    [_recorder deleteRecording];
}

@end
