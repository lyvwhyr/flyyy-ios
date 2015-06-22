//
//  AppDelegate.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "FLYNavigationController.h"
#import "FLYMainViewController.h"
#import "UIColor+FLYAddition.h"
#import "UIImage+FLYAddition.h"
#import "FLYFileManager.h"
#import "FLYGroupManager.h"
#import "FLYAudioManager.h"
#import "FLYRequestManager.h"
#import "iRate.h"
#import "FLYOnboardingStartViewController.h"
#import "FLYPushNotificationManager.h"
#import "FLYPushNotificationRouter.h"

#define MIXPANEL_TOKEN @"4ce141a1dcd56132894230aff97b282b"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Load configs from cache
    NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
    if ([defalut objectForKey:kConfigsUserDefaultKey]) {
        [FLYAppStateManager sharedInstance].configs = [defalut objectForKey:kConfigsUserDefaultKey];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasSeenFeedOnboarding = [[defaults objectForKey:kFeedOnboardingKey] boolValue];
    FLYUniversalViewController *mainVC;
    if (hasSeenFeedOnboarding) {
        mainVC = [FLYMainViewController new];
    } else {
        mainVC = [FLYOnboardingStartViewController new];
    }
    FLYNavigationController *navigationVC = [[FLYNavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = navigationVC;
    
    // It crashes in iOS 7
    if ([UIDevice version] >= 8) {
        NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*10 diskCapacity:1024*1024*100 diskPath:nil];
        [NSURLCache setSharedURLCache:urlCache];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FLYAppStateManager sharedInstance];
        [FLYFileManager sharedInstance];
        [FLYGroupManager sharedInstance];
        [FLYRequestManager sharedInstance];
    });
    
    [self _setupThirdLibraries];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    if (deviceToken) {
        NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        [FLYAppStateManager sharedInstance].deviceToken = token;
        
        FLYUser *user = [FLYAppStateManager sharedInstance].currentUser;
        [FLYPushNotificationManager setDeviceToken:user];
    }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        [[FLYPushNotificationRouter sharedInstance] routePushPayloadDict:userInfo];
    } else {
        
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        [[FLYPushNotificationRouter sharedInstance] routePushPayloadDict:userInfo];
    } else {
        
    }

}

#pragma mark - setup third party libraries
- (void)_setupThirdLibraries
{
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // set up iRate
    [iRate sharedInstance].appStoreID = [kFlyyAppID integerValue];
    [iRate sharedInstance].promptAtLaunch = NO;
    [iRate sharedInstance].promptForNewVersionIfUserRated = NO;
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].usesUntilPrompt = 0;
    [iRate sharedInstance].eventsUntilPrompt = 10; // After a user listens to the 10th post, show the prompt.
    [iRate sharedInstance].remindPeriod = 7;
    
    //Fabric should the the last one
    [Fabric with:@[CrashlyticsKit]];
}

@end
