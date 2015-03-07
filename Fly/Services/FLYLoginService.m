//
//  FLYLoginService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginService.h"

@implementation FLYLoginService

+ (instancetype)loginService
{
    return [[FLYLoginService alloc] initWithEndpoint:@"login"];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(FLYLoginUserSuccessBlock)successBlock error:(FLYLoginUserErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"phone":phoneNumber,
                             @"password":password
                             };
    [manager POST:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

@end
