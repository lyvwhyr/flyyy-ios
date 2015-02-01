//
//  CoreGraphics+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 1/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "CoreGraphics+FLYAddition.h"
#import <tgmath.h>

CGFloat FLYFloorToPixel(CGFloat f)
{
    return __tg_floor(f * [FLYUtilities FLYMainScreenScale]) / [FLYUtilities FLYMainScreenScale];
}