//
//  FLYRequestManager.m
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYRequestManager.h"
#import "FLYUsersService.h"
#import "NSDictionary+FLYAddition.h"
#import "UICKeyChainStore.h"
#import "FLYUser.h"
#import "FLYConfigService.h"
#import "FLYDeviceTokenService.h"
#import "FLYPushNotificationManager.h"
#import "FLYLoginManager.h"

@interface FLYRequestManager()

@property (nonatomic) FLYUsersService *usersService;
@property (nonatomic) FLYConfigService *configsService;

@end


@implementation FLYRequestManager

+ (instancetype)sharedInstance
{
    static FLYRequestManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [FLYRequestManager new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self _initMe];
        [self _initConfigs];
    }
    return self;
}

- (void)_initMe
{
    FLYGetMeSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        //init current logged in user
        NSDictionary *userDict = [responseObj fly_dictionaryForKey:@"user"];
        if (!userDict) {
            UALog(@"User is empty");
            return;
        }
        FLYUser *user = [[FLYUser alloc] initWithDictionary:userDict];
        [FLYAppStateManager sharedInstance].currentUser = user;
        
        // set device token
        if ([FLYAppStateManager sharedInstance].deviceToken) {
            [FLYPushNotificationManager setDeviceToken:user];
        }
        
        //save user id to NSUserDefault
        NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
        [defalut setObject:user.userId forKey:kLoggedInUserNsUserDefaultKey];
        [defalut synchronize];
        
        
        // common init
        [[FLYLoginManager sharedInstance] initAfterLogin];
        
    };
    FLYGetMeErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        
    };
    
    _usersService = [FLYUsersService usersService];
    [_usersService getMeWithsuccessBlock:successBlock error:errorBlock];
}

- (void)_initConfigs
{
    _configsService = [FLYConfigService configService];
    FLYGetConfigsSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        if (responseObj && [responseObj isKindOfClass:[NSDictionary class]]) {
            [FLYAppStateManager sharedInstance].configs = responseObj;
            
            // store configs in cache
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:responseObj forKey:kConfigsUserDefaultKey];
        }
    };
    
    FLYGetConfigsErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Error fetching configs");
    };
    [_configsService getConfigsWithSuccess:successBlock error:errorBlock];
}

@end
