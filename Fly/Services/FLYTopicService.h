//
//  FLYTopicService.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef NS_ENUM(NSInteger, FLYFeedOrderType) {
    FLYFeedOrderTypeRecent = 0,
    FLYFeedOrderTypePopular
};

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

@property FLYFeedOrderType feedOrderType;

+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds;
// topics filtered by my following tags
+ (instancetype)topicsServiceMine;
+ (instancetype)myTopics;
+ (instancetype)topicsByUserId:(NSString *)userId;

+ (void)postTopic:(NSDictionary *)dict successBlock:(FLYPostTopicSuccessBlock)successBlock errorBlock:(FLYPostTopicErrorBlock)errorBlock;
+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock;
+ (void)deleteTopicWithId:(NSString *)topicId successBlock:(FLYDeleteTopicSuccessBlock)successBlock errorBlock:(FLYDeleteTopicErrorBlock)errorBlock;
+ (void)reportTopicWithId:(NSString *)topicId;


- (instancetype)initWithFeedOrderType:(FLYFeedOrderType)feedOrderType;
- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first cursor:(BOOL)useCursor successBlock:(FLYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock;

@end
