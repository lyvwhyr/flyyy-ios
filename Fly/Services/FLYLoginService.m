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
    return [[FLYLoginService alloc] initWithEndpoint:EP_LOGIN];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(FLYLoginUserSuccessBlock)successBlock error:(FLYLoginUserErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"phone":phoneNumber,
                             @"password":password
                             };
    [manager POST:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

@end
