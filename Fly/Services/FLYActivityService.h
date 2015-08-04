//
//  FLYActivityService.h
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

//
typedef void(^FLYActivityUnreadCountSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYActivityUnreadCountErrorBlock)(id responseObj, NSError *error);

@interface FLYActivityService : FLYServiceBase

+ (void)getUnreadCount:(FLYActivityUnreadCountSuccessBlock)successBlock errorBlock:(FLYActivityUnreadCountErrorBlock)errorBlock;

@end
