//
//  FLYScribe.m
//  Flyy
//
//  Created by Xingxing Xu on 2/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYScribe.h"
#import "NSMutableDictionary+FLYAddition.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"

@interface FLYScribe()

@end

@implementation FLYScribe

+ (instancetype)sharedInstance
{
    static FLYScribe *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)logEvent:(NSString *)event section:(NSString *)section component:(NSString *)component element:(NSString *)element action:(NSString *)action
{
    NSInteger sample_rate = [[FLYAppStateManager sharedInstance].configs fly_integerForKey:@"sample_rate" defaultValue:10];
    if ((arc4random_uniform((int)sample_rate) != 0)) {
        return;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary new];
    [properties setObjectOrEmptyStr:section forKey:kTrackingSection];
    [properties setObjectOrEmptyStr:component forKey:kTrackingComponent];
    [properties setObjectOrEmptyStr:element forKey:kTrackingElement];
    [properties setObjectOrEmptyStr:action forKey:kTrackingAction];
    [properties setObjectOrEmptyStr:[FLYAppStateManager sharedInstance].currentUser.userId forKey:@"user_id"];
    
    [[Mixpanel sharedInstance] track:event properties:properties];
}

@end
