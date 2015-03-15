//
//  FLYReplyService.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

@class FLYReply;
@class FLYReplyService;
@class AFHTTPRequestOperation;

typedef void(^FLYReplyServiceGetRepliesSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYReplyServiceGetRepliesErrorBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void(^FLYReplyLikeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYReplyLikeErrorBlock)(id responseObj, NSError *error);

@interface FLYReplyService : FLYServiceBase

- (void)nextPage:(NSString *)before firstPage:(BOOL)first successBlock:(FLYReplyServiceGetRepliesSuccessBlock)successBlock errorBlock:(FLYReplyServiceGetRepliesErrorBlock)errorBlock;


+ (instancetype)replyServiceWithTopicId:(NSString *)topicId;
+ (void)likeReplyWithId:(NSString *)replyId liked:(BOOL)liked successBlock:(FLYReplyLikeSuccessBlock)successBlock errorBlock:(FLYReplyLikeErrorBlock)errorBlock;

@end
