//
//  FLYLoginService.h
//  Flyy
//
//  Created by Xingxing Xu on 3/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYLoginUserSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYLoginUserErrorBlock)(id responseObj, NSError *error);

@interface FLYLoginService : FLYServiceBase

+ (instancetype)loginService;

- (void)loginWithPhoneNumber:(NSString *)phoneNumber password:(NSString *)password success:(FLYLoginUserSuccessBlock)successBlock error:(FLYLoginUserErrorBlock)errorBlock;

@end
