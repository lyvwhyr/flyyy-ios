//
//  FLYFeedTopicTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedTopicTableViewCell.h"
#import "UIColor+FLYAddition.h"

@interface FLYFeedTopicTableViewCell()

@property (nonatomic) UIView *postHeaderView;
@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *postAtLabel;
@property (nonatomic) UILabel *categoryNameLabel;

@property (nonatomic) UIButton *playButton;


@end

@implementation FLYFeedTopicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.translatesAutoresizingMaskIntoConstraints = NO;
//        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        //header view
        _avatarImageView = [UIImageView new];
        NSString *avatarName = [NSString stringWithFormat:@"p%d.jpg", (arc4random()%4 + 1)];
        [_avatarImageView setImage:[UIImage imageNamed:avatarName]];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.text = @"pancake";
        _userNameLabel.textColor = [UIColor flyGreen];
        
        _postAtLabel = [UILabel new];
        _postAtLabel.text = @"19s";
        _postAtLabel.textColor = [UIColor flyFeedGrey];
        
        _categoryNameLabel = [UILabel new];
        _categoryNameLabel.text = @"Confession";
        
        _postHeaderView = [UIView new];
        _postHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [_postHeaderView addSubview:_avatarImageView];
        [_postHeaderView addSubview:_userNameLabel];
//        [_postHeaderView addSubview:_postAtLabel];
//        [_postHeaderView addSubview:_categoryNameLabel];
        [self.contentView addSubview:_postHeaderView];
//        _postHeaderView.backgroundColor = [UIColor flyContentBackgroundGrey];
        
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"icon_feed_play2"] forState:UIControlStateNormal];
        [self addSubview:_playButton];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//            [self setNeedsUpdateConstraints];
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
}

- (void)updateConstraints
{
//    [self mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(@(CGRectGetWidth([[UIScreen mainScreen] bounds])));
//        make.height.equalTo(@(50));
//    }];
    
    [_postHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.leading.equalTo(self.contentView).offset(0);
        make.width.equalTo(@(CGRectGetWidth([[UIScreen mainScreen] bounds])));
        make.height.equalTo(@(50));
    }];
    
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView).offset(10);
        make.leading.equalTo(_postHeaderView).offset(20);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView).offset(8);
        make.leading.equalTo(_avatarImageView.mas_right).offset(10);
//        make.width.equalTo(@(36));
//        make.height.equalTo(@(36));
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView.mas_bottom).offset(30);
        make.leading.equalTo(self).offset(20);
    }];
    
    [super updateConstraints];
}


@end
