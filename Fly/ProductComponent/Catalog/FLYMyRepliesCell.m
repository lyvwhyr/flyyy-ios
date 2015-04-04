//
//  FLYMyRepliesCell.m
//  Flyy
//
//  Created by Xingxing Xu on 4/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYMyRepliesCell.h"
#import "FLYTopic.h"
#import "FLYReply.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

#define kPlayButtonLeftPadding 16.5
#define kTopicTitleLeftPadding 15
#define kTopicTitleRightPadding 40

@interface FLYMyRepliesCell()

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *topicTitle;
@property (nonatomic) UILabel *postAt;

@property (nonatomic) BOOL didSetupConstraints;
@end

@implementation FLYMyRepliesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playButton];
        
        _topicTitle = [UILabel new];
        _topicTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _topicTitle.numberOfLines = 1;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _topicTitle.textColor = [UIColor colorWithHexString:@"#676666"];
        _topicTitle.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        [self.contentView addSubview:_topicTitle];
        
        _postAt = [UILabel new];
        _postAt.font = [UIFont fontWithName:@"Avenir-Book" size:9];
        _postAt.textColor = [UIColor flyColorFlyReplyPostAtGrey];
        [self.contentView addSubview:_postAt];
    }
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(kPlayButtonLeftPadding);
        }];
        
        [self.topicTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.playButton.mas_trailing).offset(kTopicTitleLeftPadding);
            make.trailing.lessThanOrEqualTo(self.contentView).offset(-kTopicTitleRightPadding);
            make.centerY.equalTo(self);
        }];
        
        [self.postAt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-5);
            make.centerY.equalTo(self);
        }];
    }
    
    [super updateConstraints];
}

- (void)setupCellWithTopic:(FLYTopic *)topic reply:(FLYReply *)reply
{
    self.topic = topic;
    self.reply = reply;
    
    self.topicTitle.text = self.topic.topicTitle;
    self.postAt.text = reply.displayableCreateAt;
}


@end
