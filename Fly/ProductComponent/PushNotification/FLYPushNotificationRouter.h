//
//  FLYPushNotificationRouter.h
//  Flyy
//
//  Created by Xingxing Xu on 5/25/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYPushNotificationRouter : NSObject

- (void)routePushPayloadDict:(NSDictionary *)payloadDict;

+ (FLYPushNotificationRouter *)sharedInstance;
+ (id)payloadWithDictionary:(NSDictionary *)dict;

@end
