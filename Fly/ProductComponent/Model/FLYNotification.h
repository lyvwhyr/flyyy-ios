//
//  FLYNotification.h
//  Flyy
//
//  Created by Xingxing Xu on 8/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLYTopic;

@interface FLYNotification : NSObject

@property (nonatomic) FLYTopic *topic;
@property (nonatomic, copy) NSString *action;
@property (nonatomic) BOOL isRead;
@property (nonatomic, copy) NSString *notificationString;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *displayableCreateAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
