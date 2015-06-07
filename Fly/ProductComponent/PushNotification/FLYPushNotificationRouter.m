//
//  FLYPushNotificationRouter.m
//  Flyy
//
//  Created by Xingxing Xu on 5/25/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPushNotificationRouter.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYReplyPayload.h"
#import "FLYMentionPayload.h"
#import "FLYPayload.h"

@implementation FLYPushNotificationRouter

+ (FLYPushNotificationRouter *)sharedInstance
{
    static FLYPushNotificationRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[FLYPushNotificationRouter alloc] init];
    });
    return router;
}

+ (id)payloadWithDictionary:(NSDictionary *)dict
{
    NSString *type = [dict fly_stringForKey:@"T"];
    if ([type isEqualToString:@"reply"]) {
        return [[FLYReplyPayload alloc] initWithDictionary:dict];
    } else if ([type isEqualToString:@"mention"]) {
        return [[FLYMentionPayload alloc] initWithDictionary:dict];
    }
    
    return [[FLYPayload alloc] initWithDictionary:dict];
}

- (void)routePushPayloadDict:(NSDictionary *)payloadDict
{
    id payload = [FLYPushNotificationRouter payloadWithDictionary:payloadDict];
    if ([payload isKindOfClass:[FLYReplyPayload class]]) {
        [self _handleReplyPayload:payload];
    } else if ([payload isKindOfClass:[FLYMentionPayload class]]) {
        [self _handleMentionPayload:payload];
    } else {
        UALog(@"payload type not found: %@", payloadDict);
    }
}


#pragma mark - Handle push notification payload
- (void)_handleReplyPayload:(FLYReplyPayload *)payload
{
    
}

- (void)_handleMentionPayload:(FLYMentionPayload *)payload
{
    
}

@end
