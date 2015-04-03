//
//  FLYLogoutService.h
//  Flyy
//
//  Created by Xingxing Xu on 4/2/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYLogoutSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYLogoutErrorBlock)(id responseObj, NSError *error);

@interface FLYLogoutService : FLYServiceBase

+ (void)logoutWithSuccess:(FLYLogoutSuccessBlock)successBlock error:(FLYLogoutErrorBlock)errorBlock;

@end
