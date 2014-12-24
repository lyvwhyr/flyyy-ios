//
//  FLYPlayableItem.m
//  Fly
//
//  Created by Xingxing Xu on 12/23/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPlayableItem.h"

@implementation FLYPlayableItem

- (instancetype)initWithItem:(id)item playableItemType:(FLYPlayableItemType)playableItemType playState:(FLYPlayState)playState
{
    if (self = [super init]) {
        _item = item;
        _playableItemType = playableItemType;
        _playState = playState;
    }
    return self;
}

@end
