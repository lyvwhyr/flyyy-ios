//
//  FLYTopicService.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYGetTopicsSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetTopicsErrorBlock)(id responseObj, NSError *error);
typedef void(^FLYLikeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYLikeErrorBlock)(id responseObj, NSError *error);
// delete topic
typedef void(^FLYDeleteTopicSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYDeleteTopicErrorBlock)(id responseObj, NSError *error);

// post topic
typedef void(^FLYPostTopicSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYPostTopicErrorBlock)(id responseObj, NSError *error);


@interface FLYTopicService : FLYServiceBase

+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds;
+ (instancetype)myTopics;

+ (void)postTopic:(NSDictionary *)dict successBlock:(FLYPostTopicSuccessBlock)successBlock errorBlock:(FLYPostTopicErrorBlock)errorBlock;
+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock;
+ (void)deleteTopicWithId:(NSString *)topicId successBlock:(FLYDeleteTopicSuccessBlock)successBlock errorBlock:(FLYDeleteTopicErrorBlock)errorBlock;
+ (void)reportTopicWithId:(NSString *)topicId;

- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first cursor:(BOOL)useCursor successBlock:(FLYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock;

@end
