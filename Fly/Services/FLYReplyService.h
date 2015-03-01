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

@interface FLYReplyService : FLYServiceBase

- (void)nextPage:(NSString *)before firstPage:(BOOL)first successBlock:(FLYReplyServiceGetRepliesSuccessBlock)successBlock errorBlock:(FLYReplyServiceGetRepliesErrorBlock)errorBlock;


+ (instancetype)replyServiceWithTopicId:(NSString *)topicId;

@end
