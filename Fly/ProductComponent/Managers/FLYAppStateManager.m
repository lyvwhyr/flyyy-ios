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
#import "FLYLoginViewController.h"
#import "UICKeyChainStore.h"
#import "FLYUsersService.h"
#import "NSDictionary+FLYAddition.h"
#import "Dialog.h"
#import "FLYLogoutService.h"
#import "FLYGroup.h"
#import "FLYDeviceTokenService.h"
#import "FLYActivityService.h"

#define kUnreadActivityKey @"unread_count"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_followUpdated:) name:kNotificationFollowUserChanged object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_newPostReceived:)
                                                     name:kNewPostReceivedNotification object:nil];
        
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
    FLYLoginViewController *vc = [FLYLoginViewController new];
    vc.canGoBack = YES;
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
}

- (void)_logout:(NSNotification *)notification
{
    // remove device token
    if ([FLYAppStateManager sharedInstance].deviceToken) {
        [FLYDeviceTokenService deviceToken:[FLYAppStateManager sharedInstance].deviceToken isSet:NO successBlock:nil errorBlock:nil];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kDeviceTokenUserDefaultKey];
    
    
    [FLYLogoutService logoutWithSuccess:nil error:nil];
    
    self.currentUser = nil;
    self.authToken = nil;
    self.userDefaultUserId = nil;
    self.needRestartNavigationStackAfterLogin = YES;
    [defaults removeObjectForKey:kLoggedInUserNsUserDefaultKey];
    [UICKeyChainStore removeItemForKey:kAuthTokenKey];
    
    UIViewController *fromVC = [notification.userInfo objectForKey:kFromViewControllerKey];
    FLYLoginViewController *vc = [FLYLoginViewController new];
    vc.canGoBack = NO;
    UINavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [fromVC presentViewController:nav animated:NO completion:nil];
    
    [Dialog simpleToast:LOC(@"FLYSuccessfullyLoggedOut")];
}

- (void)updateActivityCount
{
    [FLYActivityService getUnreadCount:^(AFHTTPRequestOperation *operation, id responseObj) {
        if (responseObj && [responseObj isKindOfClass:[NSDictionary class]]) {
            if ([responseObj fly_integerForKey:kUnreadActivityKey] > 0) {
                [FLYAppStateManager sharedInstance].unreadActivityCount = [responseObj fly_integerForKey:kUnreadActivityKey];
            } else {
                [FLYAppStateManager sharedInstance].unreadActivityCount = 0;
            }
            // Also call this so the notification count will be updated. The notification needs to be called outside the if statement to cover non-zero unread count to 0 read count case
            [[NSNotificationCenter defaultCenter] postNotificationName:kActivityCountUpdatedNotification object:self];
        }
    } errorBlock:^(id responseObj, NSError *error) {
        
    }];
}

- (void)clearSignedMedia
{
    self.signedURLString = nil;
    self.mediaId = nil;
    self.mineType = nil;
    self.mediaAlreadyUploaded = NO;
}

- (void)_followUpdated:(NSNotification *)notification
{
    FLYUser *user = [notification.userInfo objectForKey:@"user"];
    FLYUser *currentUser = [FLYAppStateManager sharedInstance].currentUser;
    currentUser.isFollowing = user.isFollowing;
    if (user.isFollowing) {
        currentUser.followingCount++;
    } else {
        if (currentUser.followingCount > 0) {
            currentUser.followingCount--;
        }
    }
}

- (void)_newPostReceived:(NSNotification *)notif
{
    FLYUser *currentUser = [FLYAppStateManager sharedInstance].currentUser;
    currentUser.topicCount++;
}

@end
