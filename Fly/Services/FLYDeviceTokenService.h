//
//  FLYDeviceTokenService.h
//  Flyy
//
//  Created by Xingxing Xu on 5/17/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

// set device token
typedef void(^FLYDeviceTokenSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYDeviceTokenErrorBlock)(id responseObj, NSError *error);


@interface FLYDeviceTokenService : FLYServiceBase

+ (void)deviceToken:(NSString *)deviceToken isSet:(BOOL)isSetOperation successBlock:(FLYDeviceTokenSuccessBlock)successBlock errorBlock:(FLYDeviceTokenErrorBlock)errorBlock;

@end
