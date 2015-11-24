//
//  FLYRecordViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class FLYTopic;
@class FLYGroup;

typedef NS_ENUM(NSInteger, FLYRecordState)
{
    FLYRecordInitialState = 0,
    FLYRecordRecordingState,
    FLYRecordCompleteState,
    FLYRecordPlayingState,
    FLYRecordPauseState,
    FLYRecordReadyToPlay
};

typedef NS_ENUM(NSInteger, FLYRecordingType)
{
    RecordingForTopic = 0,
    RecordingForReply,
    RecordingForAudioBio
};

@interface FLYRecordViewController : FLYUniversalViewController

@property (nonatomic) FLYRecordingType recordingType;

//reply recording
@property (nonatomic) FLYTopic *topic;
@property (nonatomic) NSString *parentReplyId;

// default selected group
@property (nonatomic) FLYGroup *defaultGroup;

- (instancetype)initWithRecordType:(FLYRecordingType)recordingType;

@end
