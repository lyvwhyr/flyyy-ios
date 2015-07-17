//
//  UIColor+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "UIColor+FLYAddition.h"


#define kColorFlyBlue                                   @"#4CA8D3"
#define kColorFlyTabBarBackground                       @"#FBFBFB"
#define kColorFlyTabBarSeparator                        @"#a3a3a5"
#define kColorFlyTabBarGreyText                         @"#bcbcbc"
#define kColorFlyLightGreen                             @"#8fbfba"
#define kColorFlyContentBackgroundGrey                  @"#eaeaea"
#define kColorFlyFeedGrey                               @"#a6a6a6"
#define kColorFlyInlineActionGrey                       @"#ababab"
#define kColorFlyTableHeaderGrey                        @"#f2f2f2"
#define kColorFlyTableHeaderTextGrey                    @"#9e9e9e"
#define kColorFlyPlayAnimation                          @"#60BD88"
#define kColorRecordingTimer                            @"#C2C2C2"
#define kColorGreen                                     @"#45BB77"
#define kColorFlyBackgroundColorBlue                    @"#4CA8D3"
#define kColorFlyGroupNameGrey                          @"#565252"
#define kColorFlyGrey                                   @"#979797"
#define kColorFlyRecordingWave                          @"#f58686"
#define kColorFlyReplyBodyTextGrey                      @"#747474"
#define kColorFlyReplyPostAtGrey                        @"#B2B2B2"
#define kColorFlyCountrySelectorBGColor                 @"#f7f7f7"
#define kColorFlyCountrySelectorCountryCodeColor        @"#8e8e93"
#define kColorFlySignupGrey                             @"#B7B5B5"
#define kColorFlyPlayAllControlPanelBackground          @"#949494"
#define kColorFlyInlineAction                           @"#B5CBD6"
#define kColorFlyHomefeedBlue                           @"#79B4D2"
#define kColorFlyButtonGreen                            @"#5FD08F"
#define kColorFlyTopicTitle                             @"#676666"
#define kColorFlyShareTextYellow                        @"#EEB17D"
#define kColorFlyShareTextBlue                          @"#4CA8D3"
#define kColorFlyShareTextGrey                          @"#9B9B9B"

@implementation UIColor (FLYAddition)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor *)flyBlue
{
    return [self colorWithHexString:kColorFlyBlue];
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

+ (UIColor *)flyFeedGrey
{
    return [self colorWithHexString:kColorFlyFeedGrey];
}

+ (UIColor *)flyInlineActionGrey
{
    return [self colorWithHexString:kColorFlyInlineActionGrey];
}

+ (UIColor *)flyBackgroundColorBlue
{
    return [self colorWithHexString:kColorFlyBackgroundColorBlue];
}

+ (UIColor *)tableHeaderGrey
{
    return [self colorWithHexString:kColorFlyTableHeaderGrey];
}

+ (UIColor *) tableHeaderTextGrey
{
    return [self colorWithHexString:kColorFlyTableHeaderTextGrey];
}

+ (UIColor *) flyColorPlayAnimation
{
    return [self colorWithHexString:kColorFlyPlayAnimation];
}

+ (UIColor *)flyColorRecordingTimer
{
    return [self colorWithHexString:kColorRecordingTimer];
}

+ (UIColor *)flyGreen
{
    return [self colorWithHexString:kColorGreen];
}

+ (UIColor *)flyColorFlyGroupNameGrey
{
    return [self colorWithHexString:kColorFlyGroupNameGrey];
}

+ (UIColor *)flyGrey
{
    return [self colorWithHexString:kColorFlyGrey];
}

+ (UIColor *)flyColorFlyRecordingWave
{
    return [self colorWithHexString:kColorFlyRecordingWave];
}

+ (UIColor *)flyColorFlyReplyBodyTextGrey
{
    return [self colorWithHexString:kColorFlyReplyBodyTextGrey];
}

+ (UIColor *)flyColorFlyReplyPostAtGrey
{
    return [self colorWithHexString:kColorFlyReplyPostAtGrey];
}

+ (UIColor *)flyColorFlyCountrySelectorBGColor
{
    return [self colorWithHexString:kColorFlyCountrySelectorBGColor];
}

+ (UIColor *)flyColorFlyCountrySelectorCountryCodeColor
{
    return [self colorWithHexString:kColorFlyCountrySelectorCountryCodeColor];
}

+ (UIColor *)flyColorFlySignupGrey
{
    return [self colorWithHexString:kColorFlySignupGrey];
}

+ (UIColor *)flyColorPlayAllControlPanelBackground
{
    return [self colorWithHexString:kColorFlyPlayAllControlPanelBackground];
}

+ (UIColor *)flyInlineAction
{
    return [self colorWithHexString:kColorFlyInlineAction];
}

+ (UIColor *)flyHomefeedBlue
{
    return [self colorWithHexString:kColorFlyHomefeedBlue];
}

+ (UIColor *)flyButtonGreen
{
    return [self colorWithHexString:kColorFlyButtonGreen];
}

+ (UIColor *)flyTopicTitleColor
{
    return [self colorWithHexString:kColorFlyTopicTitle];
}

+ (UIColor *)flyShareTextYellow
{
    return [self colorWithHexString:kColorFlyShareTextYellow];
}

+ (UIColor *)flyShareTextBlue
{
    return [self colorWithHexString:kColorFlyShareTextBlue];
}

+ (UIColor *)flyShareTextGrey
{
    return [self colorWithHexString:kColorFlyShareTextGrey];
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

+ (UIColor *)gb_greenColor
{
    return [UIColor colorWithRed:158/255.0 green:211/255.0 blue:15/255.0 alpha:1];
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
