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
    NSString *message = [NSString stringWithFormat:@"%@ %@", topic.topicTitle, @"#Flyy"];
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
    [fromVC presentViewController:avc animated:YES completion:nil];
}

@end
