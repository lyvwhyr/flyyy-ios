//
//  FLYTopicService.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTopicService.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYUser.h"

@implementation FLYTopicService

+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:EP_TOPIC_WITH_GROUP_ID_V2, groupIds]];
}

+ (instancetype)topicsServiceMine
{
    return [FLYTopicService serviceWithEndpoint:EP_TOPIC_MINE];
}

+ (instancetype)myTopics
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:EP_TOPIC_ME]];
}

+ (instancetype)topicsByUserId:(NSString *)userId
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:EP_USER_TOPICS_BY_USER_ID, userId]];
}

+ (void)postTopic:(NSDictionary *)dict successBlock:(FLYPostTopicSuccessBlock)successBlock errorBlock:(FLYPostTopicErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = EP_TOPIC_POST;
    [manager POST:endpoint parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TOPIC_LIKE, topicId];
    
    if (!liked) {
        [manager PUT:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            successBlock(operation, responseObject);
        } failure:^(id responseObj, NSError *error) {
            errorBlock(responseObj, error);
        }];
    } else {
        [manager DELETE:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            successBlock(operation, responseObject);
        } failure:^(id responseObj, NSError *error) {
            errorBlock(responseObj, error);
        }];
    }
}

+ (void)deleteTopicWithId:(NSString *)topicId successBlock:(FLYDeleteTopicSuccessBlock)successBlock errorBlock:(FLYDeleteTopicErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TOPIC_WITH_ID, topicId];
    [manager DELETE:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)reportTopicWithId:(NSString *)topicId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TOPIC_FLAG, topicId];
    [manager POST:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(id responseObj, NSError *error) {
        
    }];
}

- (instancetype)initWithFeedOrderType:(FLYFeedOrderType)feedOrderType
{
    if (self = [super init]) {
        self = [[FLYTopicService alloc] initWithEndpoint:EP_TOPIC_V2];
        _feedOrderType = feedOrderType;
    }
    return self;
}

- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first cursor:(BOOL)useCursor successBlock:(FLYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock
{
    NSInteger topicsPerPage = [[FLYAppStateManager sharedInstance].configs fly_integerForKey:@"topicsPerPage" defaultValue:kTopicPaginationCount];
    
    // for EP_USER_TOPICS_BY_USER_ID, only return 10
    if ([self.endpoint rangeOfString:@"/v1/users/"].location != NSNotFound) {
        topicsPerPage = 10;
    }
    
    NSDictionary *params = [NSDictionary new];
    if (first) {
        params = @{@"limit":@(topicsPerPage)};
    } else {
        if (useCursor) {
            params = @{@"limit":@(topicsPerPage), @"cursor":before};
        } else {
            params = @{@"limit":@(topicsPerPage), @"before":before};
        }
    }
    
    NSMutableDictionary *tempDict = [params mutableCopy];
    if (_feedOrderType == FLYFeedOrderTypePopular) {
        tempDict[@"order_by"] = @"popularity";
        params = [tempDict copy];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:self.endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(operation, error);
        }
    }];
}

@end
