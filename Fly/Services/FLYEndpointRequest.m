//
//  FLYEndpointRequest.m
//  Fly
//
//  Created by Xingxing Xu on 2/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "FLYEndpointRequest.h"

@implementation FLYEndpointRequest

+ (void)getGroupListService:(GroupListServiceResponseBlock)responseBlock
{
    NSString *baseURL = @"groups?token=secret123";
//        NSString *baseURL = @"http://localhost:3001/v1/groups?token=secret123";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
}

@end
