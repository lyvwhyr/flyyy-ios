//
//  UIColor+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "UIColor+FLYAddition.h"


#define kColorFlyGreen                          @"#36b4a7"
#define kColorFlyTabBarBackground               @"#f3f3f3"
#define kColorFlyTabBarSeparator                @"#a3a3a5"
#define kColorFlyTabBarGreyText                 @"#bcbcbc"
#define kColorFlyLightGreen                     @"#8fbfba"

@implementation UIColor (FLYAddition)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)flyGreen
{
    return [self colorWithHexString:kColorFlyGreen];
}

+ (UIColor *)flyLightGreen
{
    return [self colorWithHexString:kColorFlyLightGreen];
}

+(UIColor *)flyTabBarBackground
{
    return [self colorWithHexString:kColorFlyTabBarBackground];
}

+(UIColor *)flyTabBarSeparator
{
    return [self colorWithHexString:kColorFlyTabBarSeparator];
}

+(UIColor *)flyTabBarGreyText
{
    return [self colorWithHexString:kColorFlyTabBarGreyText];
}
@end
