//
//  FLYUtilities.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUtilities.h"

CGFloat FLYMainScreenScale()
{
    static CGFloat kScale;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^ {
        kScale = [[UIScreen mainScreen] scale];
    });
    return kScale;
}
