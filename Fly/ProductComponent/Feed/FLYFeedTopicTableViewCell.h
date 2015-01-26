//
//  FLYFeedTopicTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYFeedTopicTableViewCell;
@class FLYPost;

#import "FLYPlayableItem.h"

@protocol FLYFeedTopicTableViewCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell;
- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)cell withPost:(FLYPost *)post withIndexPath:(NSIndexPath *)indexPath;

@end

@interface FLYFeedTopicTableViewCell : UITableViewCell

@property (nonatomic) FLYPost *post;

@property id<FLYFeedTopicTableViewCellDelegate>delegate;


- (void)updatePlayState:(FLYPlayState)state;

@end
