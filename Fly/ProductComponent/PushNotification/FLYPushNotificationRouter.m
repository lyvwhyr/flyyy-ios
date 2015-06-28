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
#import "FLYTopicDetailViewController.h"
#import "FLYMainViewController.h"
#import "FLYNavigationManager.h"
#import "NSTimer+BlocksKit.h"

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
    NSString *type = [dict fly_stringForKey:@"type"];
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
    FLYNavigationManager *manager = [FLYNavigationManager sharedInstance];
 
    // Put a delay here so the MainViewController is initialized
    void (^pushViewController)() = ^{
        //1452445032827079888
        FLYTopicDetailViewController *viewController = [[FLYTopicDetailViewController alloc] initWithTopicId:payload.topicId];
        viewController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        viewController.isBackFullScreen = NO;
        viewController.viewFrameStartBelowNavBar = YES;
        [manager navigateToViewController:viewController animated:YES tabIndex:TABBAR_HOME isRoot:NO];
    };
    [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:pushViewController repeats:NO];
}

- (void)_handleMentionPayload:(FLYMentionPayload *)payload
{
    FLYNavigationManager *manager = [FLYNavigationManager sharedInstance];
    
    // Put a delay here so the MainViewController is initialized
    void (^pushViewController)() = ^{
        FLYTopicDetailViewController *viewController = [[FLYTopicDetailViewController alloc] initWithTopicId:payload.topicId];
        viewController.isBackFullScreen = NO;
        viewController.viewFrameStartBelowNavBar = YES;
        [manager navigateToViewController:viewController animated:YES tabIndex:TABBAR_HOME isRoot:NO];
    };
    [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:pushViewController repeats:NO];
}


@end
