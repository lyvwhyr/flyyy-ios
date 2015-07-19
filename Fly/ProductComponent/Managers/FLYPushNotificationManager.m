//
//  FLYPushNotificationManager.m
//  Flyy
//
//  Created by Xingxing Xu on 5/10/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPushNotificationManager.h"
#import "SCLAlertView.h"
#import "UIColor+FLYAddition.h"
#import "FLYDeviceTokenService.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYPushNotificationManager

+ (void)registerPushNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    }
}

+ (void)showEnablePushNotificationDialog:(UIViewController *)vc
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL shouldShowPushNotifDialog = [defaults boolForKey:kHasShownEnablePushNotificationDialog];
    if (!shouldShowPushNotifDialog) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addButton:LOC(@"FLYEnablePushNotificationDialogButtonText") actionBlock:^(void) {
            [FLYPushNotificationManager registerPushNotification];
        }];
        
        [alert showCustom:vc image:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] color:[UIColor flyBlue] title:LOC(@"FLYEnablePushNotificationDialogTitle") subTitle:LOC(@"FLYEnablePushNotificationDialogText") closeButtonTitle:LOC(@"FLYEnablePushNotificationDialogButtonCancel") duration:0.0f];
        
        [defaults setBool:YES forKey:kHasShownEnablePushNotificationDialog];
        [defaults synchronize];
    }
}

+ (void)setDeviceToken:(FLYUser *)loggedInUser
{
    NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
    NSString *currentDeviceToken = [FLYAppStateManager sharedInstance].deviceToken;
    
    
    NSString *loggedInUserId;
    if (loggedInUser) {
        loggedInUserId = loggedInUser.userId;
    }
    FLYDeviceTokenSuccessBlock success = ^(AFHTTPRequestOperation *operation, id responseObj) {
        if (currentDeviceToken) {
            [defalut setObject:currentDeviceToken forKey:kDeviceTokenUserDefaultKey];
            [defalut synchronize];
        }
    };
    
    FLYDeviceTokenErrorBlock error = ^(id responseObj, NSError *error) {
        if (responseObj) {
            if ([responseObj fly_integerForKey:@"code"] == kDeviceTokenAlreadyAdded) {
                if (currentDeviceToken) {
                    [defalut setObject:currentDeviceToken forKey:kDeviceTokenUserDefaultKey];
                    [defalut synchronize];
                }
            }
        }
        UALog(@"Failed to set device token, %@", responseObj);
    };
    
    [FLYDeviceTokenService deviceToken:currentDeviceToken isSet:YES successBlock:success errorBlock:error];
}

@end
