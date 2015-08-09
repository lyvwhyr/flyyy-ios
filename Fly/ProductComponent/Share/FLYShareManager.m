//
//  FLYShareManager.m
//  Flyy
//
//  Created by Xingxing Xu on 7/16/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYShareManager.h"
#import "FLYTopic.h"
#import "FLYServerConfig.h"

@implementation FLYShareManager

+ (void)shareTopicWithTopic:(FLYTopic *)topic fromViewController:(UIViewController *)fromVC
{
    [[FLYScribe sharedInstance] logEvent:@"share" section:@"share_topic" component:@"start" element:nil action:nil];
    
    NSString *message = [NSString stringWithFormat:@"Listen to \"%@\" %@", topic.topicTitle, @"#Flyy"];
    NSURL *link;
    ENV_TYPE type = [FLYServerConfig getEnv];
    
    NSString *webBaseURL;
    if (type == ENV_DEV) {
        webBaseURL = DEV_WEB_BASE_URL;
    } else if (type == ENV_STAGING) {
        webBaseURL = STAGING_WEB_BASE_URL;
    } else {
        webBaseURL = PROD_WEB_BASE_URL;
    }
    link = [NSURL URLWithString:[NSString stringWithFormat:@"%@/share/%@", webBaseURL, topic.topicId]];
    NSArray * shareItems = @[message, link];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [avc setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSDictionary *properties = @{kTrackingSection: @"share_topic", kTrackingComponent:@"complete"};
            [[Mixpanel sharedInstance]  track:@"share" properties:properties];
        }
    }];
    [fromVC presentViewController:avc animated:YES completion:nil];
}

+ (void)inviteFriends:(UIViewController *)fromVC
{
    [[FLYScribe sharedInstance] logEvent:@"share" section:@"invite_friends" component:@"start" element:nil action:nil];
    
    NSString *message = [NSString stringWithFormat:LOC(@"FLYInviteFriendsShareText"), URL_SHORT_APPLE_STORE_URL];
    NSArray * shareItems = @[message];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [avc setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSDictionary *properties = @{kTrackingSection: @"invite_friends", kTrackingComponent:@"complete"};
            [[Mixpanel sharedInstance]  track:@"share" properties:properties];
        }
    }];
    [fromVC presentViewController:avc animated:YES completion:nil];
}

@end
