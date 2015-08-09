//
//  FLYActivityService.m
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYActivityService.h"

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

- (void)nextPageWithBefore:(NSString *)before after:(NSString *)after firstPage:(BOOL)first successBlock:(FLYActivityGetSuccessBlock)successBlock errorBlock:(FLYActivityGetErrorBlock)errorBlock
{
    NSString *requestEndpoint;
    if (first) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d", EP_ACTIVITIES_GET, kActivityPaginationCount];
    } else if ([before length] > 0){
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&before=%@", EP_ACTIVITIES_GET, kActivityPaginationCount, before];
    } else if ([after length] > 0) {
        requestEndpoint = [NSString stringWithFormat: @"%@?limit=%d&after=%@", EP_ACTIVITIES_GET, kActivityPaginationCount, after];
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

@end
