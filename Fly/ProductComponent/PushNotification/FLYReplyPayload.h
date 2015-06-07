//
//  FLYReplyPayload.h
//  Flyy
//
//  Created by Xingxing Xu on 5/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPayload.h"

@interface FLYReplyPayload : FLYPayload

@property (nonatomic, copy) NSString *topicId;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
