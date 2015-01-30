//
//  FLYUser.m
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYUser

- (instancetype)initWithDictory:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict == nil) {
            UALog(@"User dictionary is empty");
            return self;
        }
        _userId = [[dict fly_objectOrNilForKey:@"user_id"] stringValue];
        _userName = [dict fly_stringForKey:@"user_name"];
    }
    return self;
}

@end
