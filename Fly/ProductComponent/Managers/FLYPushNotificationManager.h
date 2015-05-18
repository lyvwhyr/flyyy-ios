//
//  FLYPushNotificationManager.h
//  Flyy
//
//  Created by Xingxing Xu on 5/10/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYPushNotificationManager : NSObject

+ (void)registerPushNotification;
+ (void)showEnablePushNotificationDialog:(UIViewController *)vc;
+ (void)setDeviceToken:(FLYUser *)loggedInUser;

@end
