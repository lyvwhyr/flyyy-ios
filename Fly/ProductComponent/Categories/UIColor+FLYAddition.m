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
#define kColorFlyContentBackgroundGrey          @"#eaeaea"

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

+ (UIColor *)flyContentBackgroundGrey
{
    return [self colorWithHexString:kColorFlyContentBackgroundGrey];
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


#pragma mark - from external libraries
+ (UIColor *)customGrayColor
{
    return [self colorWithRed:84 green:84 blue:84];
}

+ (UIColor *)customRedColor
{
    return [self colorWithRed:231 green:76 blue:60];
}

+ (UIColor *)customYellowColor
{
    return [self colorWithRed:241 green:196 blue:15];
}

+ (UIColor *)customGreenColor
{
    return [self colorWithRed:46 green:204 blue:113];
}

+ (UIColor *)customBlueColor
{
    return [self colorWithRed:52 green:152 blue:219];
}

#pragma mark - Private class methods

+ (UIColor *)colorWithRed:(NSUInteger)red
                    green:(NSUInteger)green
                     blue:(NSUInteger)blue
{
    return [UIColor colorWithRed:(float)(red/255.f)
                           green:(float)(green/255.f)
                            blue:(float)(blue/255.f)
                           alpha:1.f];
}
@end
