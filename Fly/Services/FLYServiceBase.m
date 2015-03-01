//
//  FLYServiceBase.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYServiceBase.h"

@implementation FLYServiceBase

+ (instancetype)serviceWithEndpoint:(NSString *)endpoint
{
    return [[self alloc] initWithEndpoint:endpoint];
}

- (instancetype)initWithEndpoint:(NSString *)endpoint
{
    if (self = [super init]) {
        _endpoint = endpoint;
    }
    return self;
}

@end
