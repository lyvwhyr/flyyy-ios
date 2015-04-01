//
//  FLYFeedTopicTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYFeedTopicTableViewCell;
@class FLYTopic;
@class FLYGroup;

#import "FLYTopic.h"
#import "FLYAudioItem.h"

typedef NS_OPTIONS(NSUInteger, FLYTopicCellOptions) {
    FLYTopicCellOptionGroupName = 1 << 0,
    FLYTopicCellOptionPostAt = 1 << 1
};


@protocol FLYFeedTopicTableViewCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell;
- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)cell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath;
- (void)groupNameTapped:(FLYFeedTopicTableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@end

@interface FLYFeedTopicTableViewCell : UITableViewCell

@property (nonatomic) FLYTopic *topic;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) FLYTopicCellOptions options;
@property id<FLYFeedTopicTableViewCellDelegate>delegate;

- (void)setupTopic:(FLYTopic *)topic needUpdateConstraints:(BOOL)needUpdateConstraints;
- (void)updatePlayState:(FLYPlayState)state;
- (void)setLiked:(BOOL)liked animated:(BOOL)animated;


+ (CGFloat)heightForTopic:(FLYTopic *)topic;
@end
