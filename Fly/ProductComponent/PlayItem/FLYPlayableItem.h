//
//  FLYPlayableItem.h
//  Fly
//
//  Created by Xingxing Xu on 12/23/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "SampleQueueId.h"

#define kFeedPlayStateUpdated   @"kFeedPlayStateUpdated"

typedef NS_ENUM(NSInteger, FLYPlayState) {
    FLYPlayStateNotSet = 0,
    FLYPlayStateLoading,
    FLYPlayStatePlaying,
    FLYPlayStatePaused,
    FLYPlayStateResume,
    FLYPlayStateFinished
};

@interface FLYPlayableItem : NSObject


@property (nonatomic) id item;
@property (nonatomic) FLYPlayableItemType playableItemType;
@property (nonatomic) FLYPlayState playState;
@property (nonatomic) NSIndexPath *indexPath;

- (instancetype)initWithItem:(id)item playableItemType:(FLYPlayableItemType)playableItemType playState:(FLYPlayState)playState indexPath:(NSIndexPath *)indexPath;

@end
