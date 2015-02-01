//
//  FLYFeedTopicTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYFeedTopicTableViewCell;
@class FLYTopic;

#import "FLYPlayableItem.h"
#import "FLYTopic.h"

@protocol FLYFeedTopicTableViewCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell;
- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)cell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath;

@end

@interface FLYFeedTopicTableViewCell : UITableViewCell

@property (nonatomic) FLYTopic *topic;
@property id<FLYFeedTopicTableViewCellDelegate>delegate;

- (void)setupTopic:(FLYTopic *)topic;
- (void)updatePlayState:(FLYPlayState)state;

@end
