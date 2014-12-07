//
//  FLYFeedTopicTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYFeedTopicTableViewCell;

@protocol FLYFeedTopicTableViewCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell;

@end

@interface FLYFeedTopicTableViewCell : UITableViewCell

@property id<FLYFeedTopicTableViewCellDelegate>delegate;

@end
