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
    return [[FLYPhoneService alloc] initWithEndpoint:@"phones"];
}

- (void)serviceSendCodeWithPhone:(NSString *)number isPasswordReset:(BOOL)isPasswordReset success:(FLYSendCodeSuccessBlock)successBlock error:(FLYSendCodeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId, @"phone":number, @"reset":@(isPasswordReset)};
    [manager POST:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

- (void)serviceVerifyCode:(NSString *)code phonehash:(NSString *)phoneHash phoneNumber:(NSString *)phoneNumber success:(FLYVerifyCodeSuccessBlock)successBlock error:(FLYVerifyCodeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:@"%@/%@/verify", self.endpoint, phoneHash];
    NSDictionary *params = @{@"device_id":[FLYAppStateManager sharedInstance].deviceId, @"phone":phoneNumber, @"code":code};
    [manager GET:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

//curl -i -X GET -d "device_id=1234567" -d "phone=4153093144" "http://api-staging.flyyapp.com/v1/users/phones/2USV6T2f7GqD7b3L4-cYT8MSnwzjjr1MyoSSD9tFjpw=?device_id=1234567&code=793979"


@end
