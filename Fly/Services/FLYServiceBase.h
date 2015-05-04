//
//  FLYServiceBase.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

typedef NS_ENUM(NSInteger, FLYServiceVersion) {
    FLYServiceVersionOne = 0,
    FLYServiceVersionTwo
};

@interface FLYServiceBase : NSObject

@property (nonatomic) NSString *endpoint;

+ (instancetype)serviceWithEndpoint:(NSString *)endpoint;

- (instancetype)initWithEndpoint:(NSString *)endpoint;

- (FLYServiceVersion)serviceVersion:(NSString *)endpoint;

@end
