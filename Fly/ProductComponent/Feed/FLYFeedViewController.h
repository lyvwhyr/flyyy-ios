//
//  FLYFeedViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

typedef NS_ENUM(NSInteger, FLYFeedType) {
    FLYFeedTypeHome = 0,
    FLYFeedTypeGroup,
};

@class FLYTopicService;

#define kNewPostReceivedNotification @"kNewPostReceivedNotification"

@interface FLYFeedViewController : FLYUniversalViewController

// service
@property (nonatomic) FLYTopicService *topicService;

@property (nonatomic) BOOL isFullScreen;

// feed type. default is home
@property (nonatomic) FLYFeedType feedType;

- (BOOL)hideLeftBarItem;
- (BOOL)isFullScreen;

@end
