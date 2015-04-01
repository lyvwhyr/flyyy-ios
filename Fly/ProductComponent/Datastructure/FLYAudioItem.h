//
//  SampleQueueId.h
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//


typedef NS_ENUM(NSInteger, FLYPlayableItemType) {
    FLYPlayableItemFeedTopic =0,
    FLYPlayableItemDetailTopic,
    FLYPlayableItemDetailReply,
    FLYPlayableItemRecording
};

typedef NS_ENUM(NSInteger, FLYPlayState) {
    FLYPlayStateNotSet = 0,
    FLYPlayStateLoading,
    FLYPlayStatePlaying,
    FLYPlayStatePaused,
    FLYPlayStateResume,
    FLYPlayStateFinished
};

@interface FLYAudioItem : NSObject
@property (readwrite) int count;
@property (readwrite) NSURL* url;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) FLYPlayableItemType itemType;
@property (nonatomic) FLYPlayState playState;
@property (nonatomic) NSInteger audioDuration;

-(id) initWithUrl:(NSURL*)url andCount:(int)count indexPath:(NSIndexPath *)indexPath itemType:(FLYPlayableItemType)itemType playState:(FLYPlayState)playState audioDuration:(NSInteger)audioDuration;

@end
