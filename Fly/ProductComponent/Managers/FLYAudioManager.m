//
//  FLYAudioManager.m
//  Flyy
//
//  Created by Xingxing Xu on 2/21/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FLYAudioManager.h"
#import "FLYDownloadableAudio.h"
#import "PXAlertView.h"
#import "SDiPhoneVersion.h"

@interface FLYAudioManager()<STKAudioPlayerDelegate>

@end

@implementation FLYAudioManager

+ (instancetype)sharedInstance
{
    static FLYAudioManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        _audioPlayer.meteringEnabled = YES;
        _audioPlayer.volume = 1;
        _audioPlayer.delegate = self;
    }
    return self;
}

- (void)playAudioWithURLStr:(NSString *)str itemType:(FLYPlayableItemType)itemType
{
    NSURL* url = [NSURL URLWithString:str];
    STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:url andCount:0 indexPath:nil itemType:itemType]];
}

#pragma mark - STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    NSLog(@"state change");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"error");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{

}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"finish buffering");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(SampleQueueId *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [self.delegate didFinishPlayingWithQueueItemId:queueItemId withReason:stopReason andProgress:progress andDuration:duration];
}

- (void)checkRecordingPermissionWithSuccessBlock:(FLYRecordingPermissionGrantedSuccessBlock)successBlock
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            successBlock();
        } else {
            if (iOSVersionGreaterThanOrEqualTo(@"8")) {
                [PXAlertView showAlertWithTitle:LOC(@"FLYMicroPhonePermissionRequiredTitle")
                                        message: LOC(@"FLYMicroPhonePermissionRequiredMessageIOS8")
                                    cancelTitle:LOC(@"FLYMicroPhonePermissionCancelButton")
                                     otherTitle:LOC(@"FLYMicroPhonePermissionSettingsButton")
                                    contentView:nil
                                     completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                         if (buttonIndex == 1) {
                                             BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
                                             if (canOpenSettings) {
                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                 [[UIApplication sharedApplication] openURL:url];
                                             }
                                         }
                                     }];
            } else {
                [PXAlertView showAlertWithTitle:LOC(@"FLYMicroPhonePermissionRequiredTitle") message:LOC(@"FLYMicroPhonePermissionRequiredMessageIOS7")];
            }
        }
    }];
}

@end
