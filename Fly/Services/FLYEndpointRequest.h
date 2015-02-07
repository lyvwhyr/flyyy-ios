//
//  FLYEndpointRequest.h
//  Fly
//
//  Created by Xingxing Xu on 2/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GroupListServiceResponseBlock)(id responseObject);

@interface FLYEndpointRequest : NSObject

+ (void)getGroupListService:(GroupListServiceResponseBlock)responseBlock;

@end
