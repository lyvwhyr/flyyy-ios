//
//  FLYPost.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPost.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYPost

static int count = 1;

- (instancetype)initWithDictory:(NSDictionary *)dict
{
    if (self = [super init]) {
        _title = [dict fly_stringForKey:@"title"];
        _audioURL = [NSString stringWithFormat:@"https://ia601409.us.archive.org/6/items/new_concept_uk_level3/lesson_%.2d.mp3", count];
        count++;
    }
    return self;
}

@end
