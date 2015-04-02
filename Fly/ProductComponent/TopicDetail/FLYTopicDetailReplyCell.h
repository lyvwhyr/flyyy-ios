//
//  FLYReplyTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYAudioItem.h"

@class FLYReply;
@class FLYTopicDetailReplyCell;

@protocol FLYTopicDetailReplyCellDelegate <NSObject>

- (void)replyToReplyButtonTapped:(FLYReply *)reply;
- (void)playButtonTapped:(FLYTopicDetailReplyCell *)tappedCell withReply:(FLYReply *)reply withIndexPath:(NSIndexPath *)indexPath;

@end

@interface FLYTopicDetailReplyCell : UITableViewCell

@property (nonatomic) FLYReply *reply;
@property (nonatomic) NSIndexPath *indexPath;

@property (nonatomic, weak) id<FLYTopicDetailReplyCellDelegate> delegate;

- (void)setupReply:(FLYReply *)reply;
- (void)updatePlayState:(FLYPlayState)state;

@end
