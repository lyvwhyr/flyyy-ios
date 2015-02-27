//
//  FLYAudioManager.h
//  Flyy
//
//  Created by Xingxing Xu on 2/21/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"


@protocol FLYAudioManagerDelegate

- (void)didFinishPlayingWithQueueItemId:(SampleQueueId *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration;

-(void)stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState;

@end

@interface FLYAudioManager : NSObject

@property (nonatomic) STKAudioPlayer *audioPlayer;
@property (nonatomic) id<FLYAudioManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)playAudioWithURLStr:(NSString *)str itemType:(FLYPlayableItemType)itemType;

@end
