//
//  UIWindow+FLYAddition.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (FLYAddition)

+ (UIWindow *)keyWindow;
- (NSString *)_autolayoutTrace;

@end
