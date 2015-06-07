//
//  FLYPayload.m
//  Flyy
//
//  Created by Xingxing Xu on 5/25/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPayload.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYPayload

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *apsDict = [dict fly_dictionaryForKey:@"aps"];
        if (apsDict) {
            _alert = [apsDict fly_stringForKey:@"alert"];
            _badge = [apsDict fly_integerForKey:@"badge"];
            _sound = [apsDict fly_stringForKey:@"sound"];
        }
    }
    return self;
}

@end
