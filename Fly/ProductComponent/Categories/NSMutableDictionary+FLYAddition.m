//
//  NSMutableDictionary+FLYAddition.m
//  Flyy
//
//  Created by Xingxing Xu on 2/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "NSMutableDictionary+FLYAddition.h"

@implementation NSMutableDictionary (FLYAddition)

- (void)setObjectOrEmptyStr:(id)object forKey:(NSString *)key
{
    if (object == nil)
    {
        [self setObject:@"" forKey:key];
    } else {
        [self setObject:object forKey:key];
    }
}

@end
