//
//  FLYActivityService.h
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

@class FLYNotification;
//
typedef void(^FLYActivityUnreadCountSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYActivityUnreadCountErrorBlock)(id responseObj, NSError *error);

// get activities
typedef void(^FLYActivityGetSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYActivityGetErrorBlock)(id responseObj, NSError *error);

//mark all read
typedef void(^FLYActivityMarkAllReadSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYActivityMarkAllReadErrorBlock)(id responseObj, NSError *error);

@interface FLYActivityService : FLYServiceBase

- (void)nextPageWithCursor:(NSString *)cursor firstPage:(BOOL)first successBlock:(FLYActivityGetSuccessBlock)successBlock errorBlock:(FLYActivityGetErrorBlock)errorBlock;

+ (void)markAllRead:(FLYActivityMarkAllReadSuccessBlock)successBlock errorBlock:(FLYActivityMarkAllReadErrorBlock)errorBlock;
+ (void)getUnreadCount:(FLYActivityUnreadCountSuccessBlock)successBlock errorBlock:(FLYActivityUnreadCountErrorBlock)errorBlock;
+ (void)markSingleFollowActivityReadWithActivityId:(NSString *)actorUserId successBlock:(FLYGenericSuccessBlock)successBlock errorBlock:(FLYGenericErrorBlock)errorBlock;
+ (void)markSingleActivityRead:(FLYNotification *)notification successBlock:(FLYGenericSuccessBlock)successBlock errorBlock:(FLYGenericErrorBlock)errorBlock;

@end
