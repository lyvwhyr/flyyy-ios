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

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict == nil) {
            UALog(@"User dictionary is empty");
            return self;
        }
        _userId = [[dict fly_objectOrNilForKey:@"user_id"] stringValue];
        _userName = [dict fly_stringForKey:@"user_name"];
        _deviceId = [dict fly_stringForKey:@"device_id"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_userId forKey:@"user_id"];
    [coder encodeObject:_userName forKey:@"user_name"];
    [coder encodeObject:_deviceId forKey:@"device_id"];
    [coder encodeObject:_createdAt forKey:@"created_at"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _userId = [aDecoder decodeObjectForKey:@"user_id"];
        _userName = [aDecoder decodeObjectForKey:@"user_name"];
        _deviceId = [aDecoder decodeObjectForKey:@"device_id"];
        _createdAt = [aDecoder decodeObjectForKey:@"created_at"];
    }
    return self;
}

@end
