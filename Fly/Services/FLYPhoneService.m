//
//  FLYPhoneService.m
//  Flyy
//
//  Created by Xingxing Xu on 3/2/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPhoneService.h"

@implementation FLYPhoneService

+ (instancetype)phoneServiceWithPhoneNumber:(NSString *)phoneNumber
{
    return [[FLYPhoneService alloc] initWithEndpoint:EP_PHONE];
}

- (void)serviceSendCodeWithPhone:(NSString *)number isPasswordReset:(BOOL)isPasswordReset success:(FLYSendCodeSuccessBlock)successBlock error:(FLYSendCodeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId, @"phone":number, @"reset":@(isPasswordReset)};
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

- (void)serviceVerifyCode:(NSString *)code phonehash:(NSString *)phoneHash phoneNumber:(NSString *)phoneNumber success:(FLYVerifyCodeSuccessBlock)successBlock error:(FLYVerifyCodeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_PHONE_VERIFY, phoneHash];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId, @"phone":phoneNumber, @"code":code};
    [manager GET:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
