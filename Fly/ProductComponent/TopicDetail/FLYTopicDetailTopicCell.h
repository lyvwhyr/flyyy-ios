//
//  FLYTopicDetailTableViewCell.h
//  Flyy
//
//  Created by Xingxing Xu on 2/15/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYTopic;

@interface FLYTopicDetailTopicCell : UITableViewCell

- (void)setupTopic:(FLYTopic *)topic;

+ (CGFloat)cellHeightForTopic:(FLYTopic *)topic;

@end
