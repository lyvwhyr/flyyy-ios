//
//  FLYLoginManager.m
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginManager.h"
#import "FLYActivityService.h"
#import "NSDictionary+FLYAddition.h"

#define kUnreadActivityKey @"unread_count"

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
- (void)initAfterLogin
{
    [FLYActivityService getUnreadCount:^(AFHTTPRequestOperation *operation, id responseObj) {
        if (responseObj && [responseObj isKindOfClass:[NSDictionary class]]) {
            if ([responseObj fly_integerForKey:kUnreadActivityKey] > 0) {
                [FLYAppStateManager sharedInstance].unreadActivityCount = [responseObj fly_integerForKey:kUnreadActivityKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kActivityCountUpdatedNotification object:self];
            }
        }
    } errorBlock:^(id responseObj, NSError *error) {
        
    }];
}


@end
