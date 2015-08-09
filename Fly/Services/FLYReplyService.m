//
//  FLYReplyService.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYReplyService.h"
#import "FLYReply.h"
#import "FLYUser.h"

@implementation FLYReplyService

+ (instancetype)replyServiceWithTopicId:(NSString *)topicId
{
    NSString *endpoint = [NSString stringWithFormat: EP_REPLY_WITH_TOPIC_ID, topicId];
    return [[FLYReplyService alloc] initWithEndpoint:endpoint];
}

+ (instancetype)getMyReplies
{
    NSString *endpoint = EP_REPLY_ME;
    return [[FLYReplyService alloc] initWithEndpoint:endpoint];
}

+ (void)postReply:(NSDictionary *)params successBlock:(FLYPostReplySuccessBlock)successBlock errorBlock:(FLYPostReplyErrorBlock)errorBlock
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = EP_REPLY_POST;
    [manager POST:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(operation, responseObject);
    } failure:^(id responseObj, NSError *error) {
        errorBlock(responseObj, error);
    }];
}

- (void)nextPageWithBefore:(NSString *)before after:(NSString *)after firstPage:(BOOL)first successBlock:(FLYReplyServiceGetRepliesSuccessBlock)successBlock errorBlock:(FLYReplyServiceGetRepliesErrorBlock)errorBlock
{
    NSString *requestEndpoint;
    if (first) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", self.endpoint, KReplyPaginationCount];
    } else if ([before length] > 0){
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&before=%@", self.endpoint, KReplyPaginationCount, before];
    } else if ([after length] > 0) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&after=%@", self.endpoint, KReplyPaginationCount, after];
    } else {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", self.endpoint, KReplyPaginationCount];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(operation, error);
        }
    }];
}

+ (void)likeReplyWithId:(NSString *)replyId liked:(BOOL)liked successBlock:(FLYReplyLikeSuccessBlock)successBlock errorBlock:(FLYReplyLikeErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_REPLY_LIKE, replyId];
    
    if (!liked) {
        [manager PUT:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successBlock) {
                successBlock(operation, responseObject);
            }
        } failure:^(id responseObj, NSError *error) {
            if (errorBlock) {
                errorBlock(responseObj, error);
            }
        }];
    } else {
        [manager DELETE:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            successBlock(operation, responseObject);
        } failure:^(id responseObj, NSError *error) {
            errorBlock(responseObj, error);
        }];
    }
}

+ (void)deleteReplyWithId:(NSString *)replyId successBlock:(FLYDeleteReplySuccessBlock)successBlock errorBlock:(FLYDeleteReplyErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_REPLY_WITH_ID, replyId];
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

+ (void)reportReplyWithId:(NSString *)replyId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *endpoint = [NSString stringWithFormat:EP_REPLY_FLAG, replyId];
    [manager POST:endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(id responseObj, NSError *error) {
        
    }];
}

@end