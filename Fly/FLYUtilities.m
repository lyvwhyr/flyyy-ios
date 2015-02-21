//
//  FLYUtilities.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUtilities.h"
#import "UIWindow+FLYAddition.h"

@implementation FLYUtilities

+ (CGFloat) FLYMainScreenScale
{
    static CGFloat kScale;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^ {
        kScale = [[UIScreen mainScreen] scale];
    });
    return kScale;
}

+ (void)printAutolayoutTrace
{
    
//    [FLYUtilities performSelector:@selector(_wrapperForLoggingConstraints) withObject:nil afterDelay:.3];
}

+ (void)_wrapperForLoggingConstraints
{
    NSString *result = [[UIWindow keyWindow] _autolayoutTrace];
    NSLog(@"%@", result);
}

@end
