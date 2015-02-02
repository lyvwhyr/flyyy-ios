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
#import "FLYTopic.h"
#import "FLYIconButton.h"
#import "FLYUser.h"
#import "FLYGroup.h"

@interface FLYFeedTopicTableViewCell()

//timeline and play button
@property (nonatomic) UIImageView *timelineImageView;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

//topic content view
@property (nonatomic) UIView *topicContentView;
@property (nonatomic) UIImageView *speechBubbleView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UILabel *topicTitle;
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

#define kTopicContentBottomPadding      0
#define kTopicContentLeftPadding        5
#define kHomeTimeLineLeftPadding        25
#define kTopicContentRightPadding       10
#define kInlineActionTopPadding         10
//padding for user name, topic title to it's parent view
#define kElementLeftPadding             30
#define kElementRightPadding            10
#define kUsernameOffset                 -100

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //left timeline
        _timelineImageView = [UIImageView new];
        UIImage *timelineImage = [UIImage imageNamed:@"icon_homefeed_timeline"];
        [_timelineImageView setImage:timelineImage];
        _timelineImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_timelineImageView sizeToFit];
        [self.contentView addSubview:_timelineImageView];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"icon_homefeed_backplay"] forState:UIControlStateNormal];
        [_playButton sizeToFit];
        [self.contentView insertSubview:self.playButton aboveSubview:self.timelineImageView];
        
        //topic content view
        _topicContentView = [UIView new];
        [self.contentView addSubview:_topicContentView];
        
        _speechBubbleView = [UIImageView new];
        UIImage* image = [UIImage imageNamed:@"icon_homefeed_speech_bubble"];
        UIEdgeInsets insets = UIEdgeInsetsMake(40, 40, 70, 50);
        image = [image resizableImageWithCapInsets:insets];
        self.speechBubbleView.image = image;
//        [self.speechBubbleView sizeToFit];
        [self.topicContentView addSubview:self.speechBubbleView];
        
        _userNameLabel = [UILabel new];
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
        
        _topicTitle = [UILabel new];
        _topicTitle.numberOfLines = 2;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _topicTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _topicTitle.font = [UIFont fontWithName:@"Avenir-Book" size:17];
        _topicTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView insertSubview:self.topicTitle aboveSubview:self.speechBubbleView];
        
        //shared font
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:13];
        
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyBlue]  icon:@"icon_homefeed_wings" isIconLeft:YES]  ;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_likeButton];
        
        _groupNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _groupNameButton.titleLabel.font = inlineActionFont;
        [_groupNameButton setTitleColor:[UIColor flyBlue] forState:UIControlStateNormal];
        _groupNameButton.titleEdgeInsets = UIEdgeInsetsZero;
        [_groupNameButton sizeToFit];
        [self.topicContentView addSubview:_groupNameButton];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyBlue] icon:@"icon_homefeed_comment" isIconLeft:NO];
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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}

- (void)updateConstraints
{
    [_timelineImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(0);
        make.leading.equalTo(self).offset(kHomeTimeLineLeftPadding);
        make.height.equalTo(self);
    }];
    
    CGFloat topicContentLeftPadding = kHomeTimeLineLeftPadding + CGRectGetWidth(_timelineImageView.bounds)/2 + CGRectGetWidth(_playButton.bounds)/2 + kTopicContentLeftPadding;
    [self.topicContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(2);
        make.leading.equalTo(self.contentView).offset(topicContentLeftPadding);
        make.trailing.equalTo(self.contentView).offset(-kTopicContentRightPadding);
        make.bottom.equalTo(self.contentView).offset(-kTopicContentBottomPadding);
    }];
    
    [self.speechBubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(0);
        make.leading.equalTo(self.topicContentView).offset(0);
        make.trailing.equalTo(self.topicContentView).offset(0);
        make.bottom.equalTo(self.topicContentView).offset(-10);
    }];
    
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timelineImageView);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    if (_loadingIndicatorView) {
        [_loadingIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.playButton);
            make.centerY.equalTo(self.playButton);
        }];
    }
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(5);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
        make.width.lessThanOrEqualTo(self.topicContentView).offset(kUsernameOffset);
    }];
    
    [self.shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicContentView).offset(5);
        make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
    }];
    
    [self.topicTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameLabel.mas_bottom).offset(5);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
        make.trailing.equalTo(self.topicContentView).offset(-10);
    }];
    
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicTitle.mas_bottom).offset(kInlineActionTopPadding);
        make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
    }];
    
    [self.groupNameButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.likeButton);
        make.centerX.equalTo(self.speechBubbleView);
    }];
    
    [self.commentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.likeButton);
        make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
    }];
    
    [super updateConstraints];
}

- (UIActivityIndicatorView *)loadingIndicatorView
{
    if (_loadingIndicatorView == nil) {
        _loadingIndicatorView = [UIActivityIndicatorView new];
        _loadingIndicatorView.hidesWhenStopped = YES;
        [self.contentView insertSubview:_loadingIndicatorView aboveSubview:self.playButton];
    }
    [_loadingIndicatorView startAnimating];
    return _loadingIndicatorView;
}

#pragma mark - assign values to cell
- (void)setupTopic:(FLYTopic *)topic
{
    self.topic = topic;
    self.userNameLabel.text = topic.user.userName;
    
    self.topicTitle.text = topic.topicTitle;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _topicTitleString.length)];
    self.topicTitle.attributedText = attrStr;
    [self.topicTitle sizeToFit];
    
    [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.likeCount]];
    [self.groupNameButton setTitle:[NSString stringWithFormat:@"@%@", topic.group.groupName] forState:UIControlStateNormal];
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.replyCount]];
}

#pragma mark - update play state
- (void)updatePlayState:(FLYPlayState)state
{
    [_loadingIndicatorView stopAnimating];
    
    switch (state) {
        case FLYPlayStateNotSet: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateLoading: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backplay_bg"] forState:UIControlStateNormal];
            [self loadingIndicatorView];
            break;
        }
        case FLYPlayStatePlaying: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pausebackground"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStatePaused: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateFinished: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
    }
}

#pragma mark - inline actions
- (void)_playButtonTapped
{
    [self.delegate playButtonTapped:self withPost:self.topic withIndexPath:nil];
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
+ (CGFloat)heightForTopic:(FLYTopic *)topic
{
    CGFloat height = 0;
    
    UILabel *dummyLabel = [UILabel new];
    dummyLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    paragraphStyle.lineBreakMode= NSLineBreakByTruncatingTail;
    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topic.topicTitle.length)];
    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, topic.topicTitle.length)];
    dummyLabel.attributedText = attrStr;
    
    CGFloat rightPadding = kTopicContentRightPadding + kElementRightPadding;
    //half 5/2 timeline width, 19.5 = 117/3/ radius for play button
    CGFloat leftPadding = kElementLeftPadding + 5/2 + 19.5 + kTopicContentLeftPadding + kElementLeftPadding;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - rightPadding - leftPadding;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    
    //
    NSString *dummyString = @"dummyText";
    NSMutableAttributedString *attrStrSingleLine = [[NSMutableAttributedString alloc] initWithString:dummyString];
    paragraphStyle.lineSpacing = 2;
    [attrStrSingleLine addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, dummyString.length)];
    [attrStrSingleLine addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, dummyString.length)];
    CGRect rectSingleLine = [attrStrSingleLine boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    CGFloat labelHeight = 0.0;
    int numberOfLines = ceil(rect.size.height / rectSingleLine.size.height);
    if (numberOfLines >= 2) {
        labelHeight = rectSingleLine.size.height * 2 + paragraphStyle.lineSpacing;
    } else {
        labelHeight = rect.size.height;
    }
    //top, bottom, padding
    height += labelHeight + 44 + 70;
    
    return height;
}

@end
