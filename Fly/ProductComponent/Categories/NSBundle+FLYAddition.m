//
//  NSBundle+FLYAddition.m
//  Fly
//
//  Created by Xingxing Xu on 12/21/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "NSBundle+FLYAddition.h"

@implementation NSBundle (FLYAddition)

- (NSString *)L:(NSString *)translation_key
{
    NSString * s = NSLocalizedString(translation_key, nil);
    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"] && [s isEqualToString:translation_key]) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}

@end
