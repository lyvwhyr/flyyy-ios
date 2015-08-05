//
//  UIColor+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUtilities.h"
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
    return [FLYUtilities colorWithHexString:kColorFlyBlue];
}

+ (UIColor *)flyLightGreen
{
    return [FLYUtilities colorWithHexString:kColorFlyLightGreen];
}

+ (UIColor *)flyContentBackgroundGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyContentBackgroundGrey];
}

+(UIColor *)flyTabBarBackground
{
    return [FLYUtilities colorWithHexString:kColorFlyTabBarBackground];
}

+(UIColor *)flyTabBarSeparator
{
    return [FLYUtilities colorWithHexString:kColorFlyTabBarSeparator];
}

+(UIColor *)flyTabBarGreyText
{
    return [FLYUtilities colorWithHexString:kColorFlyTabBarGreyText];
}

+ (UIColor *)flyFeedGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyFeedGrey];
}

+ (UIColor *)flyInlineActionGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyInlineActionGrey];
}

+ (UIColor *)flyBackgroundColorBlue
{
    return [FLYUtilities colorWithHexString:kColorFlyBackgroundColorBlue];
}

+ (UIColor *)tableHeaderGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyTableHeaderGrey];
}

+ (UIColor *) tableHeaderTextGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyTableHeaderTextGrey];
}

+ (UIColor *) flyColorPlayAnimation
{
    return [FLYUtilities colorWithHexString:kColorFlyPlayAnimation];
}

+ (UIColor *)flyColorRecordingTimer
{
    return [FLYUtilities colorWithHexString:kColorRecordingTimer];
}

+ (UIColor *)flyGreen
{
    return [FLYUtilities colorWithHexString:kColorGreen];
}

+ (UIColor *)flyColorFlyGroupNameGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyGroupNameGrey];
}

+ (UIColor *)flyGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyGrey];
}

+ (UIColor *)flyColorFlyRecordingWave
{
    return [FLYUtilities colorWithHexString:kColorFlyRecordingWave];
}

+ (UIColor *)flyColorFlyReplyBodyTextGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyReplyBodyTextGrey];
}

+ (UIColor *)flyColorFlyReplyPostAtGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyReplyPostAtGrey];
}

+ (UIColor *)flyColorFlyCountrySelectorBGColor
{
    return [FLYUtilities colorWithHexString:kColorFlyCountrySelectorBGColor];
}

+ (UIColor *)flyColorFlyCountrySelectorCountryCodeColor
{
    return [FLYUtilities colorWithHexString:kColorFlyCountrySelectorCountryCodeColor];
}

+ (UIColor *)flyColorFlySignupGrey
{
    return [FLYUtilities colorWithHexString:kColorFlySignupGrey];
}

+ (UIColor *)flyColorPlayAllControlPanelBackground
{
    return [FLYUtilities colorWithHexString:kColorFlyPlayAllControlPanelBackground];
}

+ (UIColor *)flyInlineAction
{
    return [FLYUtilities colorWithHexString:kColorFlyInlineAction];
}

+ (UIColor *)flyHomefeedBlue
{
    return [FLYUtilities colorWithHexString:kColorFlyHomefeedBlue];
}

+ (UIColor *)flyButtonGreen
{
    return [FLYUtilities colorWithHexString:kColorFlyButtonGreen];
}

+ (UIColor *)flyTopicTitleColor
{
    return [FLYUtilities colorWithHexString:kColorFlyTopicTitle];
}

+ (UIColor *)flyShareTextYellow
{
    return [FLYUtilities colorWithHexString:kColorFlyShareTextYellow];
}

+ (UIColor *)flyShareTextBlue
{
    return [FLYUtilities colorWithHexString:kColorFlyShareTextBlue];
}

+ (UIColor *)flyShareTextGrey
{
    return [FLYUtilities colorWithHexString:kColorFlyShareTextGrey];
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
