//
//  FLYMediaService.h
//  Flyy
//
//  Created by Xingxing Xu on 4/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

// get signed url
typedef void(^FLYGetSignedUrlSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetSignedUrlErrorBlock)(id responseObj, NSError *error);

// upload file to s3
typedef void(^FLYUploadToS3SuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYUploadToS3ErrorBlock)(id responseObj, NSError *error);

@interface FLYMediaService : FLYServiceBase

+ (void)getSignedUrlAndUploadWithSuccessBlock:(FLYUploadToS3SuccessBlock)successBlock errorBlock:(FLYUploadToS3ErrorBlock)errorBlock;
+ (void)uploadAudioFileToS3WithSuccessBlock:(FLYUploadToS3SuccessBlock)successBlock errorBlock:(FLYUploadToS3ErrorBlock)errorBlock;

@end
