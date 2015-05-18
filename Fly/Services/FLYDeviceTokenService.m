//
//  FLYDeviceTokenService.m
//  Flyy
//
//  Created by Xingxing Xu on 5/17/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYDeviceTokenService.h"


@implementation FLYDeviceTokenService

+ (void)deviceToken:(NSString *)deviceToken isSet:(BOOL)isSetOperation successBlock:(FLYDeviceTokenSuccessBlock)successBlock errorBlock:(FLYDeviceTokenErrorBlock)errorBlock;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_SET_DEVICE_TOKEN, deviceToken];
    
    if (isSetOperation) {
        [manager PUT:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        [manager DELETE:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
