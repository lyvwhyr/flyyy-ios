//
//  FLYRecordViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

typedef NS_ENUM(NSInteger, FLYRecordState)
{
    FLYRecordInitialState = 0,
    FLYRecordRecordingState,
    FLYRecordCompleteState,
    FLYRecordPlayingState,
    FLYRecordPauseState
};

typedef NS_ENUM(NSInteger, FLYRecordingType)
{
    RecordingForTopic = 0,
    RecordingForReply
};

@interface FLYRecordViewController : FLYUniversalViewController

@property (nonatomic) FLYRecordingType recordingType;

//reply recording
@property (nonatomic) NSString *topicId;
@property (nonatomic) NSString *parentReplyId;

- (instancetype)initWithRecordType:(FLYRecordingType)recordingType;

@end
