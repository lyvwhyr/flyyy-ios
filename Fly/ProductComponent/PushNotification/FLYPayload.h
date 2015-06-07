//
//  FLYPayload.h
//  Flyy
//
//  Created by Xingxing Xu on 5/25/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYPayload : NSObject

@property (nonatomic, copy, readonly) NSString *alert;
@property (nonatomic, copy, readonly) NSString *sound;
@property (nonatomic) NSInteger badge;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
