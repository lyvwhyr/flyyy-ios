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
@class FLYIconButton;

#import "FLYTopic.h"
#import "FLYAudioItem.h"
#import "TTTAttributedLabel.h"

typedef NS_OPTIONS(NSUInteger, FLYTopicCellOptions) {
    FLYTopicCellOptionGroupName = 1 << 0,
    FLYTopicCellOptionPostAt = 1 << 1
};


@protocol FLYFeedTopicTableViewCellDelegate <NSObject>

- (void)commentButtonTapped:(FLYFeedTopicTableViewCell *)cell;
- (void)playButtonTapped:(FLYFeedTopicTableViewCell *)cell withPost:(FLYTopic *)post withIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)groupNameTapped:(FLYFeedTopicTableViewCell *)cell indexPath:(NSIndexPath *)indexPath tagId:(NSString *)tagId;

@end

@interface FLYFeedTopicTableViewCell : UITableViewCell

//play button
@property (nonatomic) UIButton *playButton;
@property (nonatomic) TTTAttributedLabel *topicTitleLabel;
@property (nonatomic) TTTAttributedLabel *userNameLabel;
@property (nonatomic) FLYIconButton *likeButton;
@property (nonatomic) FLYIconButton *commentButton;


@property (nonatomic) FLYTopic *topic;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) FLYTopicCellOptions options;
@property (nonatomic, weak) id<FLYFeedTopicTableViewCellDelegate>delegate;

- (void)setupTopic:(FLYTopic *)topic needUpdateConstraints:(BOOL)needUpdateConstraints;
- (void)updatePlayState:(FLYPlayState)state;
- (void)setLiked:(BOOL)liked animated:(BOOL)animated;


+ (CGFloat)heightForTopic:(FLYTopic *)topic;
@end
