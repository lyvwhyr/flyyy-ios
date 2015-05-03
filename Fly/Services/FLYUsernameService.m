//
//  FLYUsernameService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUsernameService.h"

@implementation FLYUsernameService

+ (instancetype)usernameService
{
    return [[FLYUsernameService alloc] initWithEndpoint:EP_USERNAME];
}

- (void)verifyUsername:(NSString *)username success:(FLYUsernameVerifySuccessBlock)successBlock error:(FLYUsernameVerifyErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_USERNAME_VERIFY, username];
    [manager GET:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

@end
