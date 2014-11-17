//
//  UIColor+FLYAddition.h
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FLYAddition)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
+(UIColor *)flyGreen;
+(UIColor *)flyTabBarBackground;
+(UIColor *)flyTabBarSeparator;
+(UIColor *)flyTabBarGreyText;

@end
