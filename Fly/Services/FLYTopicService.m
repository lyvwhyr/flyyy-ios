//
//  FLYTopicService.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTopicService.h"

@implementation FLYTopicService

+ (instancetype)topicService
{
    return [[FLYTopicService alloc] initWithEndpoint:@"topics"];
}

+ (instancetype)topicsServiceWithGroupIds:(NSString *)groupIds
{
    return [FLYTopicService serviceWithEndpoint:[NSString stringWithFormat:@"topics?group_id=%@", groupIds]];
}

+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:@"topics/%@/like", topicId];
    
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

- (void)nextPageBefore:(NSString *)before firstPage:(BOOL)first successBlock:(FlYGetTopicsSuccessBlock)successBlock errorBlock:(FLYGetTopicsErrorBlock)errorBlock
{
    NSDictionary *params = [NSDictionary new];
    if (first) {
        params = @{@"limit":@(kTopicPaginationCount)};
    } else {
        params = @{@"limit":@(kTopicPaginationCount), @"before":before};
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
