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
    NSMutableDictionary *properties = [NSMutableDictionary new];
    [properties setObjectOrEmptyStr:section forKey:@"section"];
    [properties setObjectOrEmptyStr:component forKey:@"component"];
    [properties setObjectOrEmptyStr:element forKey:@"element"];
    [properties setObjectOrEmptyStr:action forKey:@"action"];
    [properties setObjectOrEmptyStr:[FLYAppStateManager sharedInstance].currentUser.userId forKey:@"user_id"];
    
    [[Mixpanel sharedInstance] track:event properties:properties];
}

@end
