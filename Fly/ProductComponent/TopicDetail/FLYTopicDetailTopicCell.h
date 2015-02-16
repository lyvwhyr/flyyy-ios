//
//  FLYTopicDetailTableViewCell.h
//  Flyy
//
//  Created by Xingxing Xu on 2/15/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYTopic;
@class FLYTopicDetailTopicCell;

@protocol FLYTopicDetailTopicCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYTopicDetailTopicCell *)cell;

@end


@interface FLYTopicDetailTopicCell : UITableViewCell

@property (nonatomic, weak)id<FLYTopicDetailTopicCellDelegate> delegate;

- (void)setupTopic:(FLYTopic *)topic;

+ (CGFloat)cellHeightForTopic:(FLYTopic *)topic;

@end
