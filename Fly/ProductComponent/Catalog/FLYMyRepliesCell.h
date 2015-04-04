//
//  FLYMyRepliesCell.h
//  Flyy
//
//  Created by Xingxing Xu on 4/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

@class FLYTopic;
@class FLYReply;

@interface FLYMyRepliesCell : UITableViewCell

@property (nonatomic) FLYTopic *topic;
@property (nonatomic) FLYReply *reply;

- (void)setupCellWithTopic:(FLYTopic *)topic reply:(FLYReply *)reply;

@end
