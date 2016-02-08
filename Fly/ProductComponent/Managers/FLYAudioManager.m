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
#import "SDVersion.h"
#import "FLYFeedTopicTableViewCell.h"
#import "FLYAudioItem.h"
#import "FLYDownloadManager.h"

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
    [_audioPlayer setDataSource:dataSource withQueueItemId:[[FLYAudioItem alloc] initWithUrl:url andCount:0 indexPath:nil itemType:itemType playState:FLYPlayStatePlaying audioDuration:0]];
}

- (void)updateAudioState:(FLYAudioItem *)tappedAudioItem
{
    //change previous state, remove animation, change current to previous
    [FLYAudioManager sharedInstance].previousPlayItem = [FLYAudioManager sharedInstance].currentPlayItem;
    
    //If currentPlayItem is empty, set the tappedCell as currentPlayItem
    NSIndexPath *tappedCellIndexPath = tappedAudioItem.indexPath;
    [FLYAudioManager sharedInstance].currentPlayItem = tappedAudioItem;
    

    // top on the same page
    bool samePage = [FLYAudioManager sharedInstance].previousPlayItem && [FLYAudioManager sharedInstance].previousPlayItem.itemType == tappedAudioItem.itemType;
    
    NSString *audioURLStr = [tappedAudioItem.url absoluteString];
    //tap on the same cell
    if (samePage && [[FLYAudioManager sharedInstance].previousPlayItem.indexPath isEqual:tappedCellIndexPath]) {
        if ([FLYAudioManager sharedInstance].previousPlayItem.playState == FLYPlayStateNotSet) {
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateLoading;
            if ([FLYAudioManager sharedInstance].currentPlayItem.audioDuration < kStreamingMinimialLen) {
                [[FLYDownloadManager sharedInstance] loadAudioByURLString:audioURLStr audioType:FLYDownloadableTopic];
            } else {
                STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:[FLYAudioManager sharedInstance].currentPlayItem.url];
                [[FLYAudioManager sharedInstance].audioPlayer setDataSource:dataSource withQueueItemId:[[FLYAudioItem alloc] initWithUrl:[FLYAudioManager sharedInstance].currentPlayItem.url andCount:0 indexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath itemType:tappedAudioItem.itemType playState:FLYPlayStateLoading audioDuration:[FLYAudioManager sharedInstance].currentPlayItem.audioDuration]];
            }
        } else if ([FLYAudioManager sharedInstance].previousPlayItem.playState == FLYPlayStateLoading) {
            return;
        } else if ([FLYAudioManager sharedInstance].previousPlayItem.playState == FLYPlayStatePlaying) {
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePaused;
            [[FLYAudioManager sharedInstance].audioPlayer pause];
        } else if ([FLYAudioManager sharedInstance].previousPlayItem.playState == FLYPlayStatePaused) {
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
            [[FLYAudioManager sharedInstance].audioPlayer resume];
        }  else {
            [FLYAudioManager sharedInstance].previousPlayItem.playState = FLYPlayStateFinished;
            [[FLYAudioManager sharedInstance].audioPlayer stop];
        }
    } else {
        //tap on a different cell
        [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateLoading;
        if ([FLYAudioManager sharedInstance].currentPlayItem.audioDuration < kStreamingMinimialLen) {
            [[FLYDownloadManager sharedInstance] loadAudioByURLString:audioURLStr audioType:FLYDownloadableTopic];
        } else {
            NSURL* url = [NSURL URLWithString:audioURLStr];
            STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:url];
            [[FLYAudioManager sharedInstance].audioPlayer setDataSource:dataSource withQueueItemId:[[FLYAudioItem alloc] initWithUrl:url andCount:0 indexPath:[FLYAudioManager sharedInstance].currentPlayItem.indexPath itemType:tappedAudioItem.itemType playState:FLYPlayStateLoading audioDuration:[FLYAudioManager sharedInstance].currentPlayItem.audioDuration]];
            
            [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStateLoading;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAudioPlayStateChanged object:self];
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

#pragma mark - STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    NSLog(@"state change");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    NSLog(@"error");
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(FLYAudioItem *)queueItemId
{
    [FLYAudioManager sharedInstance].currentPlayItem.playState = FLYPlayStatePlaying;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAudioPlayStateChanged object:self];
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(FLYAudioItem *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    
    if (queueItemId) {
        NSDictionary *dict = @{kAudioStopReasonKey:@(stopReason), kAudioItemkey:queueItemId};
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidFinishPlaying object:self userInfo:dict];
    } else {
        UALog(@"queueItemid is nil");
    }
}

@end
