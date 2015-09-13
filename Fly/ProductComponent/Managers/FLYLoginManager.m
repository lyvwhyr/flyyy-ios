//
//  FLYLoginManager.m
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginManager.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYUser.h"
#import "FLYGroup.h"
#import "FLYPushNotificationManager.h"

@implementation FLYLoginManager

+ (instancetype)sharedInstance
{
    static FLYLoginManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[FLYLoginManager alloc] init];
    });
    return manager;
}

// This method is called after a user successfully logged in either through login, sign up or auth/me
- (void)initAfterLogin:(NSDictionary *)data
{
    NSMutableDictionary *userDict = [[data fly_dictionaryForKey:@"user"] mutableCopy];
    if ([data fly_arrayForKey:@"tags"]) {
        userDict[@"tags"] = [data fly_arrayForKey:@"tags"];
    }
    
    FLYUser *currentUser = [[FLYUser alloc] initWithDictionary:userDict];
    [FLYAppStateManager sharedInstance].currentUser = currentUser;
    
    //save user id to NSUserDefault
    NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
    [defalut setObject:currentUser.userId forKey:kLoggedInUserNsUserDefaultKey];
    [defalut synchronize];
    
    // set device token
    if ([FLYAppStateManager sharedInstance].deviceToken) {
        [FLYPushNotificationManager setDeviceToken:currentUser];
    }
    
    [[FLYAppStateManager sharedInstance] updateActivityCount];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuccessfulLoginNotification object:self];
}


@end
