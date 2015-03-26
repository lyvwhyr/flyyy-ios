//
//  FLYConfigService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/24/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYConfigService.h"

@implementation FLYConfigService

+ (instancetype)configService
{
    return [[FLYConfigService alloc] initWithEndpoint:@"configs"];
}

- (void)getConfigsWithSuccess:(FLYGetConfigsSuccessBlock)successBlock error:(FLYGetConfigsErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:self.endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

@end
