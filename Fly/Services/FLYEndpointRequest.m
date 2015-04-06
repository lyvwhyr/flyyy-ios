//
//  FLYEndpointRequest.m
//  Fly
//
//  Created by Xingxing Xu on 2/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "FLYEndpointRequest.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYEndpointRequest

#define kMultiPartName @"media"
#define kMultiPartFileName @"dummyName.m4a"
#define kMimeType @"audio/mp4a-latm"
#define kMediaIdGeneratedNotification @"kMediaIdGeneratedNotification"

+ (void)getGroupListService:(GroupListServiceResponseBlock)responseBlock
{
    NSString *baseURL = @"groups";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
}

+ (void)createUserWithUsername:(NSString *)username deviceId:(NSString *)deviceId successBlock:(userCreationSuccessBlock)success
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"device_id":deviceId, @"user_name":username};
    [manager POST:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
}

@end
