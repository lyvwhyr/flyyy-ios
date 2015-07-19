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
    return [[FLYConfigService alloc] initWithEndpoint:EP_CONFIG];
}

- (void)getConfigsWithSuccess:(FLYGetConfigsSuccessBlock)successBlock error:(FLYGetConfigsErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:self.endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
