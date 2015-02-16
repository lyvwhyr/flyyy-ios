//
//  FLYReplyTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYReply;

@interface FLYTopicDetailReplyCell : UITableViewCell

@property (nonatomic) FLYReply *reply;

- (void)setupReply:(FLYReply *)reply;

@end
