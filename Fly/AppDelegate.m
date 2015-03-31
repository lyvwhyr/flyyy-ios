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

#define MIXPANEL_TOKEN @"4ce141a1dcd56132894230aff97b282b"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    FLYMainViewController *mainVC = [FLYMainViewController new];
    FLYNavigationController *navigationVC = [[FLYNavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = navigationVC;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FLYAppStateManager sharedInstance];
        [FLYFileManager sharedInstance];
        [FLYGroupManager sharedInstance];
        [FLYRequestManager sharedInstance];
//        [FLYAudioManager sharedInstance];
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
    UALog(@"DELEGATE: Device Token is: %@", deviceToken);
    if (deviceToken) {
        NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        [FLYAppStateManager sharedInstance].deviceToken = token;
        
        NSDictionary *params = @{@"device_token":token};
//        [EPRequest epSetDeviceInfo:params];
    }
}

#pragma mark - setup third party libraries
- (void)_setupThirdLibraries
{
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    
    //Fabric should the the last one
    [Fabric with:@[CrashlyticsKit]];
}

@end
