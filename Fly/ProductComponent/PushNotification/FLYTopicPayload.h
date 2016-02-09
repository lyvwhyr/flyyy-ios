//
//  FLYTopicPayload.h
//  Flyy
//
//  Created by Xingxing Xu on 2/8/16.
//  Copyright © 2016 Fly. All rights reserved.
//

#import "FLYPayload.h"

@interface FLYTopicPayload : FLYPayload

@property (nonatomic, copy) NSString *topicId;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
