//
//  FLYRequestManager.m
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYRequestManager.h"
#import "FLYUsersService.h"
#import "NSDictionary+FLYAddition.h"
#import "UICKeyChainStore.h"
#import "FLYUser.h"

@interface FLYRequestManager()

@property (nonatomic) FLYUsersService *usersService;

@end


@implementation FLYRequestManager

+ (instancetype)sharedInstance
{
    static FLYRequestManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [FLYRequestManager new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self _initMe];
    }
    return self;
}

- (void)_initMe
{
    FLYGetMeSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        //init current logged in user
        NSDictionary *userDict = [responseObj fly_dictionaryForKey:@"user"];
        if (!userDict) {
            UALog(@"User is empty");
            return;
        }
        FLYUser *user = [[FLYUser alloc] initWithDictionary:userDict];
        [FLYAppStateManager sharedInstance].currentUser = user;
        
        //save user id to NSUserDefault
        NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
        [defalut setObject:user.userId forKey:kLoggedInUserNsUserDefaultKey];
        [defalut synchronize];
    };
    FLYGetMeErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        UALog(@"%@", responseObj);
    };
    
    _usersService = [FLYUsersService usersService];
    [_usersService getMeWithsuccessBlock:successBlock error:errorBlock];
}

@end
