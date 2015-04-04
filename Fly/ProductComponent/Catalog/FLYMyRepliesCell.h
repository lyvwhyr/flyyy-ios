//
//  FLYMyRepliesCell.h
//  Flyy
//
//  Created by Xingxing Xu on 4/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYAudioItem.h"

@class FLYTopic;
@class FLYReply;
@class FLYMyRepliesCell;

@protocol FLYMyRepliesCellDelegate <NSObject>

- (void)playButtonTapped:(FLYMyRepliesCell *)cell withIndexPath:(NSIndexPath *)indexPath;

@end

@interface FLYMyRepliesCell : UITableViewCell

@property (nonatomic) FLYTopic *topic;
@property (nonatomic) FLYReply *reply;
@property (nonatomic) NSIndexPath *indexPath;
@property id<FLYMyRepliesCellDelegate>delegate;

- (void)setupCellWithTopic:(FLYTopic *)topic reply:(FLYReply *)reply;
- (void)updatePlayState:(FLYPlayState)state;

@end
