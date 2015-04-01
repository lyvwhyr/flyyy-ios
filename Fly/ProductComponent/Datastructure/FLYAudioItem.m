//
//  SampleQueueId.m
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//

#import "FLYAudioItem.h"

@implementation FLYAudioItem

-(id) initWithUrl:(NSURL*)url andCount:(int)count indexPath:(NSIndexPath *)indexPath itemType:(FLYPlayableItemType)itemType playState:(FLYPlayState)playState;
{
    if (self = [super init])
    {
        _url = url;
        _count = count;
        _indexPath = indexPath;
        _itemType = itemType;
        _playState = playState;
    }
    
    return self;
}

-(BOOL) isEqual:(id)object
{
    if (object == nil)
    {
        return NO;
    }
    
    if ([object class] != [FLYAudioItem class])
    {
        return NO;
    }
    
    return [((FLYAudioItem*)object).url isEqual: self.url] && ((FLYAudioItem*)object).count == self.count
            && ((FLYAudioItem*)object).itemType == self.itemType && ((FLYAudioItem*)object).playState == self.playState;
}

-(NSString*) description
{
    return [self.url description];
}

@end
