//
//  FLYTopicPayload.m
//  Flyy
//
//  Created by Xingxing Xu on 2/8/16.
//  Copyright © 2016 Fly. All rights reserved.
//

#import "FLYTopicPayload.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYTopicPayload

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super initWithDictionary:dict]) {
        _topicId = [dict fly_stringForKey:@"tid"];
    }
    return self;
}

@end
