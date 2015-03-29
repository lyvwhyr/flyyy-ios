//
//  FLYTopicService.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FlYGetTopicsSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetTopicsErrorBlock)(id responseObj, NSError *error);
typedef void(^FLYLikeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYLikeErrorBlock)(id responseObj, NSError *error);
//delete topic
typedef void(^FLYDeleteTopicSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYDeleteTopicErrorBlock)(id responseObj, NSError *error);

@interface FLYTopicService : FLYServiceBase

+ (instancetype)topicService;
+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds;

+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock;
+ (void)deleteTopicWithId:(NSString *)topicId successBlock:(FLYDeleteTopicSuccessBlock)successBlock errorBlock:(FLYDeleteTopicErrorBlock)errorBlock;

- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first successBlock:(FlYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock;

@end
