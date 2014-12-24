//
//  FLYPlayableItem.h
//  Fly
//
//  Created by Xingxing Xu on 12/23/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#define kFeedPlayStateUpdated   @"kFeedPlayStateUpdated"

typedef NS_ENUM(NSInteger, FLYPlayableItemType) {
    FLYPlayableFeed = 0,
    FLYPlayableDetail
};

typedef NS_ENUM(NSInteger, FLYPlayState) {
    FLYPlayStateNotSet = 0,
    FLYPlayStatePlaying,
    FLYPlayStatePaused,
    FLYPlayStateFinished
};

@interface FLYPlayableItem : NSObject

@property (nonatomic) id item;
@property (nonatomic) FLYPlayableItemType playableItemType;
@property (nonatomic) FLYPlayState playState;

- (instancetype)initWithItem:(id)item playableItemType:(FLYPlayableItemType)playableItemType playState:(FLYPlayState)playState;

@end
