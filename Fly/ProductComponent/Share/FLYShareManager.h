//
//  FLYShareManager.h
//  Flyy
//
//  Created by Xingxing Xu on 7/16/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLYTopic;

@interface FLYShareManager : NSObject

+ (void)shareTopicWithTopic:(FLYTopic *)topic fromViewController:(UIViewController *)fromVC;
+ (void)inviteFriends:(UIViewController *)fromVC;
+ (void)shareTag:(UIViewController *)fromVC tagName:(NSString *)tagName;

@end
