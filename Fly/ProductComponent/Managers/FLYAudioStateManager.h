//
//  FLYAudioStateManager.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class AEAudioController;
@class AERecorder;
@class AEAudioFilePlayer;
@class FLYPlayableItem;

typedef void (^AudioPlayerCompleteblock)();

@interface FLYAudioStateManager : NSObject

#define kUseRecordAndPlaybackNotification @"kUseRecordAndPlaybackNotification"
#define kUsePlaybackOnlyNotification @"kUsePlaybackOnlyNotification"

@property (nonatomic) AEAudioController *audioController;

@property (nonatomic) AERecorder *recorder;
@property (nonatomic) AEAudioFilePlayer *player;

@property (nonatomic) FLYPlayableItem *previousPlayItem;
@property (nonatomic) FLYPlayableItem *currentPlayItem;

- (void)startRecord;
- (void)stopRecord;
- (void)pausePlayer;
- (void)resumePlayer;
- (void)removePlayer;
- (void)applyFilter;
- (void)removeFilter;
- (void)initRecordingAudioController;
- (void)playAudioURLStr:(NSString *)str withCompletionBlock:(AudioPlayerCompleteblock)block;
- (void)playAudioWithCompletionBlock:(AudioPlayerCompleteblock)block;

+ (instancetype)sharedInstance;

@end
