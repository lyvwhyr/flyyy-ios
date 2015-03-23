//
//  FLYUsernameService.h
//  Flyy
//
//  Created by Xingxing Xu on 3/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYUsernameVerifySuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYUsernameVerifyErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface FLYUsernameService : FLYServiceBase

+ (instancetype)usernameService;
- (void)verifyUsername:(NSString *)username success:(FLYUsernameVerifySuccessBlock)successBlock error:(FLYUsernameVerifyErrorBlock)errorBlock;

@end
