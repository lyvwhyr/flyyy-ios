//
//  NSDictionary+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "NSDictionary+FLYAddition.h"

@implementation NSDictionary (FLYAddition)

- (NSString *)fly_stringForKey:(id)key
{
    return [self fly_stringForKey:key defaultValue:nil];
}

- (NSString *)fly_stringForKey:(id)key defaultValue:(NSString *)defaultVal
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[obj class]]) {
        return obj;
    }
    return defaultVal;
}

- (NSArray *)fly_arrayForKey:(id)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[obj class]]) {
        return obj;
    }
    return nil;
}

- (NSDictionary *)fly_dictionaryForKey:(id)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[obj class]]) {
        return obj;
    }
    return nil;
}

- (BOOL)fly_boolForKey:(id)key defaultValue:(BOOL)defaultVal
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(boolValue)]) {
        return [obj boolValue];
    }
    return defaultVal;
}

- (NSInteger)fly_integerForKey:(id)key defaultValue:(NSInteger)defaultVal
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(integerValue)]) {
        return [obj integerValue];
    }
    return defaultVal;
}

- (NSInteger)fly_integerForKey:(id)key
{
    return [self fly_integerForKey:key defaultValue:0];
}

- (float)fly_floatForKey:(id)key defaultValue:(float)defaultVal
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(floatValue)]) {
        return [obj floatValue];
    }
    return defaultVal;
}

- (float)fly_floatForKey:(id)key
{
    return [self fly_floatForKey:key defaultValue:0];
}

- (long long)fly_longLongForKey:(id)key defaultValue:(long long)defaultVal
{
    id obj = [self objectForKey:key];
    if ([obj respondsToSelector:@selector(longLongValue)]) {
        return [obj longLongValue];
    }
    return defaultVal;
}

- (long long)fly_longLongForKey:(id)key
{
    return [self fly_longLongForKey:key defaultValue:0];
}
            

@end
