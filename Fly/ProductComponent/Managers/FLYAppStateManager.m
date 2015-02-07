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
        _isAutoPlayEnabled = YES;
        
        //set up http request base url
        [[NSUserDefaults standardUserDefaults] setObject:[FLYServerConfig getServerURL] forKey:kBaseURLInPreference];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

@end
