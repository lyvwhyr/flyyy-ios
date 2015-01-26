//
//  FLYFeedTopicTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedTopicTableViewCell.h"
#import "UIColor+FLYAddition.h"
#import "FLYIconButton.h"
#import "FLYInlineActionView.h"
#import "UIImage+FLYAddition.h"
#import "FLYPost.h"

@interface FLYFeedTopicTableViewCell()



@property (nonatomic) UIView *postHeaderView;
@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *postAtLabel;
@property (nonatomic) FLYIconButton *categoryButton;

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *postTitle;

@property (nonatomic) FLYInlineActionView *inlineActionView;

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
        NSString *avatarName = [NSString stringWithFormat:@"p%d.jpg", (arc4random()%10 + 1)];
        UIImage *avatarImage = [UIImage imageNamed:avatarName];
        [_avatarImageView setImage:avatarImage];
        [_avatarImageView sizeToFit];
        _avatarImageView.layer.cornerRadius = 18;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _userNameLabel = [UILabel new];
        _userNameLabel.text = @"pancake";
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _postAtLabel = [UILabel new];
        _postAtLabel.text = @"19s";
        _postAtLabel.font = [UIFont systemFontOfSize:13];
        _postAtLabel.textColor = [UIColor flyFeedGrey];
        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        

        _categoryButton = [[FLYIconButton alloc] initWithText:@"Small business saturday" textFont:[UIFont systemFontOfSize:12] textColor:[UIColor flyInlineActionGrey] icon:@"icon_feed_group"];
        _categoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_categoryButton];
        
        _postHeaderView = [UIView new];
        _postHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [_postHeaderView addSubview:_avatarImageView];
        [_postHeaderView addSubview:_userNameLabel];
        [_postHeaderView addSubview:_postAtLabel];
        [self.contentView addSubview:_postHeaderView];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"icon_feed_play"] forState:UIControlStateNormal];
        [self addSubview:_playButton];
        
        _postTitle = [UILabel new];
        _postTitle.numberOfLines = 0;
        _postTitle.textColor = [UIColor blackColor];
        _postTitle.font = [UIFont systemFontOfSize:15];
        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *postTitle = @"There's a fine line between numerator and denominator.";
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:postTitle];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 6;
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, postTitle.length)];
        _postTitle.attributedText = attrStr;
        [_postTitle sizeToFit];
        [self addSubview:_postTitle];
        
        _inlineActionView = [FLYInlineActionView new];
        _inlineActionView.translatesAutoresizingMaskIntoConstraints = NO;
        __weak typeof(self)weakSelf = self;
        _inlineActionView.commentButtonTappedBlock = ^ {
            __strong typeof(self)strongSelf = weakSelf;
            [strongSelf.delegate commentButtonTapped:strongSelf];
        };
        [self addSubview:_inlineActionView];
        
    }
    return self;
}

- (void)updatePlayState:(FLYPlayState)state
{
    switch (state) {
        case FLYPlayStateNotSet: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_feed_play"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateLoading: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_play_loading"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStatePlaying: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_play_pause"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStatePaused: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_feed_play"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateFinished: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_feed_play"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_feed_play"] forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [_postHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(0);
        make.leading.equalTo(self.contentView).offset(0);
        make.width.equalTo(@(CGRectGetWidth([[UIScreen mainScreen] bounds])));
        make.height.equalTo(@(50));
    }];
    
    [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView).offset(10);
        make.leading.equalTo(_postHeaderView).offset(20);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_avatarImageView);
        make.leading.equalTo(_avatarImageView.mas_right).offset(10);
//        make.width.equalTo(@(36));
//        make.height.equalTo(@(36));
    }];
    
    [_categoryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameLabel.mas_bottom).offset(3);
        make.leading.equalTo(_userNameLabel);
    }];
    
    [_postAtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView).offset(15);
        make.trailing.equalTo(_postHeaderView).offset(-20);
    }];
    
    
    //center part
    [_playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView.mas_bottom).offset(20);
        make.leading.equalTo(self).offset(25);
    }];
    
    [_postTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_postHeaderView.mas_bottom).offset(5);
        make.leading.equalTo(_playButton.mas_trailing).offset(20);
        make.width.lessThanOrEqualTo(self).offset(-40 - 36);
    }];
    
    [_inlineActionView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_playButton.mas_bottom);
        make.bottom.equalTo(self);
        make.leading.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@(40));
    }];
    
    [super updateConstraints];
}

- (void)_playButtonTapped
{
    [self.delegate playButtonTapped:self withPost:self.post withIndexPath:nil];
}


@end
