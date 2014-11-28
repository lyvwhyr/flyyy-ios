//
//  NSDictionary+FLYAddition.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FLYAddition)

- (NSString *)fly_stringForKey:(id)key;
- (NSString *)fly_stringForKey:(id)key defaultValue:(NSString *)defaultVal;
- (NSArray *)fly_arrayForKey:(id)key;
- (NSDictionary *)fly_dictionaryForKey:(id)key;
- (BOOL)fly_boolForKey:(id)key defaultValue:(BOOL)defaultVal;
- (NSInteger)fly_integerForKey:(id)key defaultValue:(NSInteger)defaultVal;
- (NSInteger)fly_integerForKey:(id)key;
- (float)fly_floatForKey:(id)key defaultValue:(float)defaultVal;
- (float)fly_floatForKey:(id)key;
- (long long)fly_longLongForKey:(id)key defaultValue:(long long)defaultVal;
- (long long)fly_longLongForKey:(id)key;

@end
