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
            [FLYAppStateManager sharedInstance].unreadActivityCount = [responseObj fly_integerForKey:@"undrea_count"];
        }
    } errorBlock:^(id responseObj, NSError *error) {
        
    }];
}


@end
