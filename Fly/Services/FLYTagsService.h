//
//  FLYTagsService.h
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

@interface FLYTagsService : FLYServiceBase

typedef void(^FLYFollowTagSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYFollowTagErrorBlock)(id responseObj, NSError *error);

typedef void(^FLYGetGlobalTagsSuccessBlock)(AFHTTPRequestOperation *operation, id responseObj);
typedef void(^FLYGetGlobalTagsErrorBlock)(id responseObj, NSError *error);

+ (void)followTagWithId:(NSString *)tagId followed:(BOOL)followed successBlock:(FLYFollowTagSuccessBlock)successBlock errorBlock:(FLYFollowTagErrorBlock)errorBlock;

- (void)nextPageWithCursor:(NSString *)cursor firstPage:(BOOL)first successBlock:(FLYGetGlobalTagsSuccessBlock)successBlock errorBlock:(FLYGetGlobalTagsErrorBlock)errorBlock;

@end
