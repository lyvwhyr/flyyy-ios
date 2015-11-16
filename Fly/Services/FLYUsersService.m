//
//  FLYUsersService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUsersService.h"

@implementation FLYUsersService

+ (instancetype)usersService
{
    return [[FLYUsersService alloc] initWithEndpoint:EP_USER];
}

- (void)createUserWithPhoneHash:(NSString *)phoneHash code:(NSString *)code userName:(NSString *)userName password:(NSString *)password success:(FLYCreateUserSuccessBlock)successBlock error:(FLYCreateuserErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId,
                             @"phone_hash":phoneHash,
                             @"code":code,
                             @"user_name":userName,
                             @"password":password
                             };
    [manager POST:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
        UALog(@"create user error %@", error);
    }];
}

- (void)resetPasswordWithPhoneHash:(NSString *)phoneHash code:(NSString *)code password:(NSString *)password success:(FLYResetPasswordSuccessBlock)successBlock error:(FLYResetPasswordErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId,
                             @"phone_hash":phoneHash,
                             @"code":code,
                             @"password":password
                             };
    [manager POST:EP_USER_RESET parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

- (void)getMeWithsuccessBlock:(FLYGetMeSuccessBlock)successBlock error:(FLYGetMeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:EP_USER_ME parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)getUserWithUserId:(NSString *)userId successBlock:(FLYGetUserByUserIdSuccessBlock)successBlock error:(FLYGetUserByUserIdErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endPoint = [NSString stringWithFormat:EP_USER_WITH_USER_ID, userId];
    [manager GET:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)renameUserWithNewUsername:(NSString *)newUsername successBlock:(FLYRenameSuccessBlock)successBlock error:(FLYRenameErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"new_user_name":newUsername};
    [manager POST:EP_USER_RENAME parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)followUserByUserId:(NSString *)userId isFollow:(BOOL)isFollow successBlock:(FLYFollowUserByUserIdSuccessBlock)successBlock error:(FLYFollowUserByUserIdErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endPoint = [NSString stringWithFormat:EP_USER_FOLLOW_BY_USER_ID, userId];
    if (isFollow) {
        [manager PUT:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        [manager DELETE:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    }
}

@end
