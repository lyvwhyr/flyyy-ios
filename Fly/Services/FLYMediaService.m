//
//  FLYMediaService.m
//  Flyy
//
//  Created by Xingxing Xu on 4/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYMediaService.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYMediaService

+ (void)getSignedUrlAndUploadWithSuccessBlock:(FLYUploadToS3SuccessBlock)successBlock errorBlock:(FLYUploadToS3ErrorBlock)errorBlock
{
    [[FLYAppStateManager sharedInstance] clearSignedMedia];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"media/sign" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObj) {
        if (successBlock) {
            if (responseObj) {
                [FLYAppStateManager sharedInstance].signedURLString = [responseObj fly_stringForKey:@"url"];
                [FLYAppStateManager sharedInstance].mineType = [responseObj fly_stringForKey:@"content_type"];
                [FLYAppStateManager sharedInstance].mediaId = [[responseObj fly_objectOrNilForKey:@"media_id"] stringValue];
                
                FLYUploadToS3SuccessBlock uploadSuccessBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
                    [FLYAppStateManager sharedInstance].mediaAlreadyUploaded = YES;
                    successBlock(operation, responseObj);
                };
                
                FLYUploadToS3ErrorBlock uploadErrorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (errorBlock) {
                        errorBlock(responseObj, error);
                    }
                };
                [FLYMediaService uploadAudioFileToS3WithSuccessBlock:uploadSuccessBlock errorBlock:uploadErrorBlock];
            } else {
                [[FLYAppStateManager sharedInstance] clearSignedMedia];
            }
        }
    } failure:^(id responseObj, NSError *error) {
        if (errorBlock) {
            errorBlock(responseObj, error);
        }
    }];
}

+ (void)uploadAudioFileToS3WithSuccessBlock:(FLYUploadToS3SuccessBlock)successBlock errorBlock:(FLYUploadToS3ErrorBlock)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSData *audioData=[NSData dataWithContentsOfFile:[FLYAppStateManager sharedInstance].recordingFilePathSelected];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"PUT" URLString:[FLYAppStateManager sharedInstance].signedURLString parameters:nil error:nil];
    [request setHTTPBody:audioData];
    [request setValue:[FLYAppStateManager sharedInstance].mineType forHTTPHeaderField: @"Content-Type"];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                              success:^(AFHTTPRequestOperation *op, NSHTTPURLResponse *response) {
                                                                                  if (successBlock) {
                                                                                      successBlock(op, response);
                                                                                  }
                                                                              }
                                                                              failure:^(AFHTTPRequestOperation *op, NSError *error) {
                                                                                  NSLog(@"%@", error);
                                                                                  if (errorBlock) {
                                                                                      errorBlock(op, error);
                                                                                  }
                                                                              }];
    [manager.operationQueue addOperation:operation];
    
}

@end
