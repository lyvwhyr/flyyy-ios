//
//  FLYServiceBase.h
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYServiceBase : NSObject

@property (nonatomic) NSString *endpoint;

+ (instancetype)serviceWithEndpoint:(NSString *)endpoint;

- (instancetype)initWithEndpoint:(NSString *)endpoint;

@end
