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
#import "FLYUser.h"
#import "PXAlertView.h"

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

+ (BOOL)isInvalidUser
{
    if (![FLYAppStateManager sharedInstance].currentUser) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRequireSignupNotification object:self];
        return YES;
    }
    
    // user is suspended
    if ([FLYAppStateManager sharedInstance].currentUser.suspended) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYAccountSuspendedMessage")];
        return YES;
    }
    
    return NO;
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

+ (void)gotoReviews
{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kFlyyAppID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

+ (NSString*) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end
