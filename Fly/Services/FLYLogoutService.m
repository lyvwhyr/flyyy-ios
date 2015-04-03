//
//  FLYLogoutService.m
//  Flyy
//
//  Created by Xingxing Xu on 4/2/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLogoutService.h"

@implementation FLYLogoutService

+ (void)logoutWithSuccess:(FLYLogoutSuccessBlock)successBlock error:(FLYLogoutErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
