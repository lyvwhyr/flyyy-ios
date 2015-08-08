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

// get activities
typedef void(^FLYActivityGetSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYActivityGetErrorBlock)(id responseObj, NSError *error);

@interface FLYActivityService : FLYServiceBase

- (void)nextPageWithBefore:(NSString *)before after:(NSString *)after firstPage:(BOOL)first successBlock:(FLYActivityGetSuccessBlock)successBlock errorBlock:(FLYActivityGetErrorBlock)errorBlock;

+ (void)getUnreadCount:(FLYActivityUnreadCountSuccessBlock)successBlock errorBlock:(FLYActivityUnreadCountErrorBlock)errorBlock;

@end
