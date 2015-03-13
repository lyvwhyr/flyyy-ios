//
//  FLYUtilities.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUtilities.h"
#import "UIWindow+FLYAddition.h"
#import "FLYCountryListDatasource.h"

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

+ (CGFloat)hairlineHeight
{
    return 1.0/[FLYUtilities FLYMainScreenScale];
}

+ (void)printAutolayoutTrace
{
    
    [FLYUtilities performSelector:@selector(_wrapperForLoggingConstraints) withObject:nil afterDelay:.3];
}

+ (void)_wrapperForLoggingConstraints
{
#ifdef DEBUG
    NSString *result = [[UIWindow keyWindow] _autolayoutTrace];
    NSLog(@"%@", result);
#endif
}

+ (NSString *)getCountryDialCode
{
    FLYCountryListDatasource *countryDataSource = [FLYCountryListDatasource new];
    NSArray *countries = countryDataSource.allCountries;
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *countryDialCode;
    for (int i = 0; i < countries.count; i++) {
        NSString *countryNameCode = [countries[i] objectForKey:kPhoneCodeKey];
        if ([countryCode isEqualToString:countryNameCode]) {
            countryDialCode = [countries[i] objectForKey:kPhoneDialCodeKey];
            break;
        }
    }
    if ([countryDialCode length] == 0) {
        [[FLYScribe sharedInstance] logEvent:@"client_error" section:@"invid_country_code" component:countryCode element:nil action:nil];
    }
    return countryDialCode;
}

@end
