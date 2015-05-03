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

+ (instancetype)topicService
{
    return [[FLYTopicService alloc] initWithEndpoint:EP_TOPIC];
}

+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:EP_TOPIC_WITH_GROUP_ID, groupIds]];
}

+ (instancetype)myTopics
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:EP_TOPIC_ME]];
}

+ (void)postTopic:(NSDictionary *)dict successBlock:(FLYPostTopicSuccessBlock)successBlock errorBlock:(FLYPostTopicErrorBlock)errorBlock
{
    
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_TOPIC_POST, userId];
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

- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first successBlock:(FlYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock
{
    NSInteger topicsPerPage = [[FLYAppStateManager sharedInstance].configs fly_integerForKey:@"topicsPerPage" defaultValue:kTopicPaginationCount];
    
    NSDictionary *params = [NSDictionary new];
    if (first) {
        params = @{@"limit":@(topicsPerPage)};
    } else {
        params = @{@"limit":@(topicsPerPage), @"before":before};
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
