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
#import "Dialog.h"
#import "FLYLogoutService.h"

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
        _configs = [NSMutableDictionary new];
        [self _initSession];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requireSignupOrLogin:) name:kRequireSignupNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_logout:) name:kNotificationLogout object:nil];
        
    }
    return self;
}

- (void)_initSession
{
    NSString *authToken = [UICKeyChainStore stringForKey:kAuthTokenKey];
    if (authToken) {
        _authToken = authToken;
    }
}

- (NSString *)userDefaultUserId
{
    if (!_userDefaultUserId) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults objectForKey:kLoggedInUserNsUserDefaultKey];
    }
    return _userDefaultUserId;
}

- (void)_requireSignupOrLogin:(NSNotification *)notification
{
    UIViewController *fromVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    FLYLoginSignupViewController *vc = [FLYLoginSignupViewController new];
    vc.canGoBack = YES;
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
}

- (void)_logout:(NSNotification *)notification
{
    [FLYLogoutService logoutWithSuccess:nil error:nil];
    
    self.currentUser = nil;
    self.authToken = nil;
    self.userDefaultUserId = nil;
    self.needRestartNavigationStackAfterLogin = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kLoggedInUserNsUserDefaultKey];
    
    UIViewController *fromVC = [notification.userInfo objectForKey:kFromViewControllerKey];
    FLYLoginSignupViewController *vc = [FLYLoginSignupViewController new];
    vc.canGoBack = NO;
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
    
    [Dialog simpleToast:LOC(@"FLYSuccessfullyLoggedOut")];
}

- (void)clearSignedMedia
{
    self.signedURLString = nil;
    self.mediaId = nil;
    self.mineType = nil;
    self.mediaAlreadyUploaded = NO;
}

@end
