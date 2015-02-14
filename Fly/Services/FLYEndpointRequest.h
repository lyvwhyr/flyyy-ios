//
//  FLYEndpointRequest.h
//  Fly
//
//  Created by Xingxing Xu on 2/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GroupListServiceResponseBlock)(id responseObject);
typedef void(^mediaUploadSuccessBlock)(NSString *mediaId);
typedef void(^mediaUploadFailureBlock)();

@interface FLYEndpointRequest : NSObject

+ (void)getGroupListService:(GroupListServiceResponseBlock)responseBlock;
+ (void)uploadAudioFileServiceWithSuccessBlock:(mediaUploadSuccessBlock)successBlock failureBlock:(mediaUploadFailureBlock)fail
;

@end
