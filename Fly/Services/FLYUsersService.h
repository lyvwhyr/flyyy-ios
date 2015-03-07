//
//  FLYUsersService.h
//  Flyy
//
//  Created by Xingxing Xu on 3/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYCreateUserSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYCreateuserErrorBlock)(id responseObj, NSError *error);

// users/me
typedef void(^FLYGetMeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetMeErrorBlock)(id responseObj, NSError *error);

@interface FLYUsersService : FLYServiceBase

+ (instancetype)usersService;

- (void)createUserWithPhoneHash:(NSString *)phoneHash code:(NSString *)code userName:(NSString *)userName password:(NSString *)password success:(FLYCreateUserSuccessBlock)successBlock error:(FLYCreateuserErrorBlock)errorBlock;
- (void)getMeWithsuccessBlock:(FLYGetMeSuccessBlock)successBlock error:(FLYGetMeErrorBlock)errorBlock;

@end
