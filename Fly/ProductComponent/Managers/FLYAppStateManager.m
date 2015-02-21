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
    }
    return self;
}

@end
