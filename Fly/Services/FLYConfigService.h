//
//  FLYConfigService.h
//  Flyy
//
//  Created by Xingxing Xu on 3/24/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYGetConfigsSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetConfigsErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface FLYConfigService : FLYServiceBase

+ (instancetype)configService;
- (void)getConfigsWithSuccess:(FLYGetConfigsSuccessBlock)successBlock error:(FLYGetConfigsErrorBlock)errorBlock;

@end
