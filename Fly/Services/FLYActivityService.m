//
//  FLYActivityService.m
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYActivityService.h"
#import "FLYNotification.h"
#import "FLYTopic.h"
#import "FLYReply.h"

@implementation FLYActivityService

+ (void)getUnreadCount:(FLYActivityUnreadCountSuccessBlock)successBlock errorBlock:(FLYActivityUnreadCountErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:EP_ACTIVITIES_UNREAD_COUNT parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

- (void)nextPageWithCursor:(NSString *)cursor firstPage:(BOOL)first successBlock:(FLYActivityGetSuccessBlock)successBlock errorBlock:(FLYActivityGetErrorBlock)errorBlock
{
    NSString *requestEndpoint;
    if (first) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", EP_ACTIVITIES_GET, kActivityPaginationCount];
    } else if ([cursor length] > 0){
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&cursor=%@", EP_ACTIVITIES_GET, kActivityPaginationCount, cursor];
    } else {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", EP_ACTIVITIES_GET, kActivityPaginationCount];
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

+ (void)markAllRead:(FLYActivityMarkAllReadSuccessBlock)successBlock errorBlock:(FLYActivityMarkAllReadErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:EP_ACTIVITIES_MARK_READ parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)markSingleFollowActivityReadWithActivityId:(NSString *)actorUserId successBlock:(FLYGenericSuccessBlock)successBlock errorBlock:(FLYGenericErrorBlock)errorBlock
{
    NSString *ep = [NSString stringWithFormat:EP_ACTIVITIES_MARK_FOLLOWED_READ, actorUserId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:ep parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)markSingleActivityRead:(FLYNotification *)notification successBlock:(FLYGenericSuccessBlock)successBlock errorBlock:(FLYGenericErrorBlock)errorBlock
{
    
    NSString *action = notification.action;
    NSString *actionId;
    if ([action isEqualToString:kFLYNotificationTypeReplyLiked]) {
        actionId = notification.reply.replyId;
    } else if ([action isEqualToString:kFLYNotificationTypeTopicLiked]) {
        actionId = notification.topic.topicId;
    }
    
    NSString *ep = [NSString stringWithFormat:EP_ACTIVITIES_MARK_SINGLE_READ, action, actionId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:ep parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock(operation, responseObject);
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

@end
