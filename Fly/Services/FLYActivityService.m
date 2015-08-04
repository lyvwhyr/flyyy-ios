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

@end
