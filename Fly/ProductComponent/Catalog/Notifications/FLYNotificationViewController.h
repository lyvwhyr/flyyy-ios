//
//  FLYNotificationViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class FLYTopic;
@class FLYUser;

@protocol FLYNotificationViewControllerDelegate <NSObject>

- (void)visitTopicDetail:(FLYTopic *)topic;
- (void)visitProfile:(FLYUser *)user;

@end

@interface FLYNotificationViewController : FLYUniversalViewController

@property (nonatomic, weak) id<FLYNotificationViewControllerDelegate> delegate;

@end
