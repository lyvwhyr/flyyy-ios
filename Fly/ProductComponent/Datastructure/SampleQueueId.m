//
//  SampleQueueId.m
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//

#import "SampleQueueId.h"

@implementation SampleQueueId

-(id) initWithUrl:(NSURL*)url andCount:(int)count indexPath:(NSIndexPath *)indexPath itemType:(FLYPlayableItemType)itemType
{
    if (self = [super init])
    {
        _url = url;
        _count = count;
        _indexPath = indexPath;
        _itemType = itemType;
    }
    
    return self;
}

-(BOOL) isEqual:(id)object
{
    if (object == nil)
    {
        return NO;
    }
    
    if ([object class] != [SampleQueueId class])
    {
        return NO;
    }
    
    return [((SampleQueueId*)object).url isEqual: self.url] && ((SampleQueueId*)object).count == self.count
            && ((SampleQueueId*)object).itemType == self.itemType;
}

-(NSString*) description
{
    return [self.url description];
}

@end
