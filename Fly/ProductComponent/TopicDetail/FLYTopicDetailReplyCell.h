//
//  FLYReplyTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYReply;

@protocol FLYTopicDetailReplyCellDelegate <NSObject>

- (void)replyToReplyButtonTapped:(FLYReply *)reply;

@end

@interface FLYTopicDetailReplyCell : UITableViewCell

@property (nonatomic) FLYReply *reply;
@property (nonatomic, weak) id<FLYTopicDetailReplyCellDelegate> delegate;

- (void)setupReply:(FLYReply *)reply;

@end
