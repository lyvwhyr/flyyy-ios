//
//  FLYGroup.h
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYGroup : NSObject

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic) NSInteger topicCount;

- (instancetype)initWithDictory:(NSDictionary *)dict;

@end
