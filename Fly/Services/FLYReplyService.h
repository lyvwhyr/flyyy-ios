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

// get my replies
typedef void(^FLYGetMyRepliesSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetMyRepliesErrorBlock)(id responseObj, NSError *error);

// delete reply
typedef void(^FLYDeleteReplySuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYDeleteReplyErrorBlock)(id responseObj, NSError *error);

@interface FLYReplyService : FLYServiceBase

- (void)nextPage:(NSString *)before firstPage:(BOOL)first successBlock:(FLYReplyServiceGetRepliesSuccessBlock)successBlock errorBlock:(FLYReplyServiceGetRepliesErrorBlock)errorBlock;


+ (instancetype)replyServiceWithTopicId:(NSString *)topicId;
+ (instancetype)getMyReplies;
+ (void)likeReplyWithId:(NSString *)replyId liked:(BOOL)liked successBlock:(FLYReplyLikeSuccessBlock)successBlock errorBlock:(FLYReplyLikeErrorBlock)errorBlock;
+ (void)deleteReplyWithId:(NSString *)replyId successBlock:(FLYDeleteReplySuccessBlock)successBlock errorBlock:(FLYDeleteReplyErrorBlock)errorBlock;
+ (void)reportReplyWithId:(NSString *)replyId;

@end
