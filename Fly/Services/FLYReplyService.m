//
//  FLYReplyService.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYReplyService.h"
#import "FLYReply.h"

@implementation FLYReplyService

+ (instancetype)replyServiceWithTopicId:(NSString *)topicId
{
    NSString *endpoint = [NSString stringWithFormat: @"topics/%@", topicId];
    return [[FLYReplyService alloc] initWithEndpoint:endpoint];
}

- (void)nextPage:(NSString *)before firstPage:(BOOL)first successBlock:(FLYReplyServiceGetRepliesSuccessBlock)successBlock errorBlock:(FLYReplyServiceGetRepliesErrorBlock)errorBlock
{
    NSString *requestEndpoint;
    if (first) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", self.endpoint, KReplyPaginationCount];
    } else {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&before=%@", self.endpoint, KReplyPaginationCount, before];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(operation, error);
    }];
}

@end