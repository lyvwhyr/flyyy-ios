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

@interface FLYRecordViewController : FLYUniversalViewController

@end
