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

//reset password
typedef void(^FLYResetPasswordSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYResetPasswordErrorBlock)(id responseObj, NSError *error);

// users/me
typedef void(^FLYGetMeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetMeErrorBlock)(id responseObj, NSError *error);

// users/%@
typedef void(^FLYGetUserByUserIdSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetUserByUserIdErrorBlock)(id responseObj, NSError *error);

// users/rename
typedef void(^FLYRenameSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYRenameErrorBlock)(id responseObj, NSError *error);

@interface FLYUsersService : FLYServiceBase

+ (instancetype)usersService;
+ (void)renameUserWithNewUsername:(NSString *)newUsername successBlock:(FLYRenameSuccessBlock)successBlock error:(FLYRenameErrorBlock)errorBlock;
+ (void)getUserWithUserId:(NSString *)userId successBlock:(FLYGetUserByUserIdSuccessBlock)successBlock error:(FLYGetUserByUserIdErrorBlock)errorBlock;


- (void)createUserWithPhoneHash:(NSString *)phoneHash code:(NSString *)code userName:(NSString *)userName password:(NSString *)password success:(FLYCreateUserSuccessBlock)successBlock error:(FLYCreateuserErrorBlock)errorBlock;
- (void)resetPasswordWithPhoneHash:(NSString *)phoneHash code:(NSString *)code password:(NSString *)password success:(FLYResetPasswordSuccessBlock)successBlock error:(FLYResetPasswordErrorBlock)errorBlock;
- (void)getMeWithsuccessBlock:(FLYGetMeSuccessBlock)successBlock error:(FLYGetMeErrorBlock)errorBlock;

@end
