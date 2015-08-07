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
@property (nonatomic, copy) NSString *notificationString;


@end
