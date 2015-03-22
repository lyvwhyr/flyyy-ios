//
//  FLYAppStateManager.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYAppStateManager.h"
#import "FLYServerConfig.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIDevice+FLYAddition.h"
#import "FLYUser.h"
#import "FLYSignupPhoneNumberViewController.h"
#import "FLYNavigationController.h"
#import "FLYLoginSignupViewController.h"
#import "UICKeyChainStore.h"
#import "FLYUsersService.h"
#import "NSDictionary+FLYAddition.h"

@interface FLYAppStateManager()

@property (nonatomic) FLYUsersService *usersService;

@end

@implementation FLYAppStateManager

+ (instancetype)sharedInstance
{
    static FLYAppStateManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [FLYAppStateManager new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _isAutoPlayEnabled = NO;
        _deviceId = [UIDevice uniqueDeviceIdentifier];
        [self _initSession];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requireSignupOrLogin:) name:kRequireSignupNotification object:nil];
        
    }
    return self;
}

- (void)_initSession
{
    NSString *authToken = [UICKeyChainStore stringForKey:kAuthTokenKey];
    if (authToken) {
        _authToken = authToken;
    }
    [UICKeyChainStore removeItemForKey:kAuthTokenKey];
}

- (void)_requireSignupOrLogin:(NSNotification *)notification
{
    UIViewController *fromVC = [notification.userInfo objectForKey:kFromViewControllerKey];
    FLYLoginSignupViewController *vc = [FLYLoginSignupViewController new];
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
}

@end
