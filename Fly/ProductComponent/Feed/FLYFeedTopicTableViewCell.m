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
#import "FLYIconButton.h"

@interface FLYFeedTopicTableViewCell()

//timeline and play button
@property (nonatomic) UIImageView *timelineImageView;
@property (nonatomic) UIButton *playButton;

//topic content view
@property (nonatomic) UIView *topicContentView;
@property (nonatomic) UIImageView *speechBubbleView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UILabel *postTitle;
@property (nonatomic) FLYIconButton *likeButton;
@property (nonatomic) UIButton *groupNameButton;
@property (nonatomic) FLYIconButton *commentButton;


//TODO:remove unused
@property (nonatomic) UILabel *postAtLabel;
@property (nonatomic) FLYIconButton *categoryButton;
@property (nonatomic) FLYInlineActionView *inlineActionView;


@property (nonatomic, copy) NSString *topicTitleString;

@end

@implementation FLYFeedTopicTableViewCell

#define kTopicContentLeftPadding    5
#define kHomeTimeLineLeftPadding    25
//padding for user name, topic title to it's parent view
#define kElementLeftPadding         30
#define kElementRightPadding        10

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //left timeline
        _timelineImageView = [UIImageView new];
        UIImage *timelineImage = [UIImage imageNamed:@"icon_homefeed_timeline"];
        [_timelineImageView setImage:timelineImage];
        _timelineImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_timelineImageView];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"icon_homefeed_backplay"] forState:UIControlStateNormal];
        [self.contentView insertSubview:self.playButton aboveSubview:self.timelineImageView];
        
        //topic content view
        _topicContentView = [UIView new];
        [self.contentView addSubview:_topicContentView];
        
        _speechBubbleView = [UIImageView new];
        UIImage* image = [UIImage imageNamed:@"icon_homefeed_speech_bubble"];
        UIEdgeInsets insets = UIEdgeInsetsMake(40, 40, 70, 50);
        image = [image resizableImageWithCapInsets:insets];
        self.speechBubbleView.image = image;
        [self.speechBubbleView sizeToFit];
        [self.topicContentView addSubview:self.speechBubbleView];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.text = @"pancake";
        _userNameLabel.textColor = [UIColor flyBlue];
        _userNameLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:18];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_userNameLabel];
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_shareButton addTarget:self action:@selector(_shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton setImage:[UIImage imageNamed:@"icon_homefeed_share"] forState:UIControlStateNormal];
        [_shareButton sizeToFit];
        [self.topicContentView addSubview:_shareButton];
        
        _postTitle = [UILabel new];
        _postTitle.numberOfLines = 2;
        _postTitle.adjustsFontSizeToFitWidth = NO;
        _postTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _postTitle.font = [UIFont fontWithName:@"Avenir-Book" size:17];
        _postTitle.translatesAutoresizingMaskIntoConstraints = NO;
        _topicTitleString = @"There's a fine line between numerator and here's a fine line between numerator and denominator. There's a fine line between numerator and denominator.";
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_topicTitleString];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 2;
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _topicTitleString.length)];
        _postTitle.attributedText = attrStr;
        [_postTitle sizeToFit];
        [self.topicContentView insertSubview:self.postTitle aboveSubview:self.speechBubbleView];
        
        //shared font
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:13];
        
        _likeButton = [[FLYIconButton alloc] initWithText:@"10" textFont:inlineActionFont textColor:[UIColor flyBlue]  icon:@"icon_homefeed_wings"];
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_likeButton];
        
        _groupNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _groupNameButton.titleLabel.font = inlineActionFont;
        [_groupNameButton setTitleColor:[UIColor flyBlue] forState:UIControlStateNormal];
        [_groupNameButton setTitle:@"@confession" forState:UIControlStateNormal];
        _groupNameButton.titleEdgeInsets = UIEdgeInsetsZero;
        [_groupNameButton sizeToFit];
        [self.topicContentView addSubview:_groupNameButton];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"10" textFont:inlineActionFont textColor:[UIColor flyBlue] icon:@"icon_homefeed_comment"];
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton sizeToFit];
        [self.topicContentView addSubview:_commentButton];

        
//
//        _postAtLabel = [UILabel new];
//        _postAtLabel.text = @"19s";
//        _postAtLabel.font = [UIFont systemFontOfSize:13];
//        _postAtLabel.textColor = [UIColor flyFeedGrey];
//        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        
//
//        _categoryButton = [[FLYIconButton alloc] initWithText:@"Small business saturday" textFont:[UIFont systemFontOfSize:12] textColor:[UIColor flyInlineActionGrey] icon:@"icon_feed_group"];
//        _categoryButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:_categoryButton];
        
//        _postHeaderView = [UIView new];
//        _postHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
//        [_postHeaderView addSubview:_avatarImageView];
//        [_postHeaderView addSubview:_userNameLabel];
//        [_postHeaderView addSubview:_postAtLabel];
//        [self.contentView addSubview:_postHeaderView];
        
//
//        _inlineActionView = [FLYInlineActionView new];
//        _inlineActionView.translatesAutoresizingMaskIntoConstraints = NO;
//        __weak typeof(self)weakSelf = self;
//        _inlineActionView.commentButtonTappedBlock = ^ {
//            __strong typeof(self)strongSelf = weakSelf;
//            [strongSelf.delegate commentButtonTapped:strongSelf];
//        };
//        [self addSubview:_inlineActionView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [_timelineImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(0);
        make.leading.equalTo(self).offset(kHomeTimeLineLeftPadding);
        make.height.equalTo(@(150));
    }];
    
    [_playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timelineImageView);
        make.top.equalTo(self.contentView).offset(90);
    }];
    
    CGFloat topicContentLeftPadding = CGRectGetMaxX(_playButton.frame) + kTopicContentLeftPadding;
    [self.topicContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.leading.equalTo(self.contentView).offset(topicContentLeftPadding);
        make.trailing.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
    
    [self.speechBubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(0);
        make.leading.equalTo(self.topicContentView).offset(0);
        make.trailing.equalTo(self.topicContentView).offset(0);
        make.bottom.equalTo(self.topicContentView).offset(0);
    }];
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(5);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
    }];
    
    [self.shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(5);
        make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
    }];
    
    [self.postTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(5);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
        make.trailing.equalTo(self.topicContentView).offset(-10);
    }];
    
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.postTitle.mas_bottom).offset(5);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
    }];
    
    [self.groupNameButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.likeButton);
        make.centerX.equalTo(self.speechBubbleView);
    }];
    
    [self.commentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.postTitle.mas_bottom).offset(5);
        make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
    }];
    
    [super updateConstraints];
}

#pragma mark - update play state
- (void)updatePlayState:(FLYPlayState)state
{
    switch (state) {
        case FLYPlayStateNotSet: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backplay"] forState:UIControlStateNormal];
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

#pragma mark - inline actions
- (void)_playButtonTapped
{
    [self.delegate playButtonTapped:self withPost:self.post withIndexPath:nil];
}

- (void)_likeButtonTapped
{
    
}

- (void)_shareButtonTapped
{
    
}

- (void)_commentButtonTapped
{
    
}

#pragma mark - Height of the cell
- (CGFloat)heightForTopic:(FLYPost *)post
{
    CGFloat height = 0;
    NSString *title = post.topicTitle;
    
    
    return height;
}

@end
