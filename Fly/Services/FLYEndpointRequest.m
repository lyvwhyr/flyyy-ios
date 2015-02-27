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
    NSString *baseURL = @"groups?token=secret123";
//        NSString *baseURL = @"http://localhost:3001/v1/groups?token=secret123";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
}

//curl -X POST -F "media=@/Users/xingxingxu/Desktop/11223632430542967739.m4a" -i "http://localhost:3000/v1/media/upload?token=secret123&user_id=1349703091376390371"
+ (void)uploadAudioFileServiceWithUserId:(NSString *)userId successBlock:(mediaUploadSuccessBlock)successBlock failureBlock:(mediaUploadFailureBlock)fail
{
    [FLYAppStateManager sharedInstance].mediaId = nil;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"media/upload?token=secret123&user_id=%@", userId];
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *audioData=[NSData dataWithContentsOfFile:[FLYAppStateManager sharedInstance].recordingFilePath];
        [formData appendPartWithFileData:audioData name: kMultiPartName fileName: kMultiPartFileName mimeType:kMimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [FLYAppStateManager sharedInstance].mediaId = [[responseObject fly_objectOrNilForKey:@"media_id"] stringValue];
        if (successBlock) {
            successBlock([FLYAppStateManager sharedInstance].mediaId);
        }
        UALog(@"Post audio file response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail();
        }
        NSLog(@"Error: %@", error);
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
