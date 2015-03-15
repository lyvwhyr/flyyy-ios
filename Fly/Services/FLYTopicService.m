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

@end
