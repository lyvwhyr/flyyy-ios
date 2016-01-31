//
//  UIFont+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "UIFont+FLYAddition.h"

#define MAX_CACHE_SIZE      30

@implementation UIFont (FLYAddition)

+(UIFont *)flyToolBarFont
{
    UIFont *font = [UIFont systemFontOfSize:11.0];
    return font;
}

+ (UIFont *)flyFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Book" size:size];
}

+ (UIFont *)flyLightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Light" size:size];
}

+ (UIFont *)flyBlackFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Avenir-Black" size:size];
}

@end
