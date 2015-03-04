//
//  FLYPhoneService.h
//  Flyy
//
//  Created by Xingxing Xu on 3/2/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYSendCodeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYSendCodeErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

typedef void(^FLYVerifyCodeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYVerifyCodeErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface FLYPhoneService : FLYServiceBase

+ (instancetype)phoneServiceWithPhoneNumber:(NSString *)phoneNumber;

- (void)serviceSendCodeWithPhone:(NSString *)number success:(FLYSendCodeSuccessBlock)successBlock error:(FLYSendCodeErrorBlock)errorBlock;

- (void)serviceVerifyCode:(NSString *)code phonehash:(NSString *)phoneHash phoneNumber:(NSString *)phoneNumber success:(FLYVerifyCodeSuccessBlock)successBlock error:(FLYVerifyCodeErrorBlock)errorBlock;

@end
