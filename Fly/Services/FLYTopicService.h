//
//  FLYTopicService.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

typedef void(^FLYLikeSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYLikeErrorBlock)(id responseObj, NSError *error);

@interface FLYTopicService : FLYServiceBase

+ (instancetype)topicService;

+ (void)likeTopicWithId:(NSString *)topicId liked:(BOOL)liked successBlock:(FLYLikeSuccessBlock)successBlock errorBlock:(FLYLikeErrorBlock)errorBlock;

@end
