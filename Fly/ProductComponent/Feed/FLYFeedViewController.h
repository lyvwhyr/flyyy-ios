//
//  FLYFeedViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class FLYTopicService;

#define kNewPostReceivedNotification @"kNewPostReceivedNotification"


@interface FLYFeedViewController : FLYUniversalViewController

// service
@property (nonatomic) FLYTopicService *topicService;

- (void)clearCurrentPlayingItem;

@end
