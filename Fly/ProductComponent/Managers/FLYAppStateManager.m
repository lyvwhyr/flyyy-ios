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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requireSignup:) name:kRequireSignupNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requireLogin) name:kRequireLoginNotification object:nil];
        
    }
    return self;
}

- (void)_requireSignup:(NSNotification *)notification
{
    UIViewController *fromVC = [notification.userInfo objectForKey:kFromViewControllerKey];
    FLYSignupPhoneNumberViewController *vc = [FLYSignupPhoneNumberViewController new];
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
}

@end
