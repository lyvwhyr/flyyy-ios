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
    return [[FLYUsersService alloc] initWithEndpoint:@"users"];
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

- (void)getMeWithsuccessBlock:(FLYGetMeSuccessBlock)successBlock error:(FLYGetMeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:@"%@/%@", self.endpoint, @"me"];
    [manager GET:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}


@end
