//
//  FLYTopicDetailTableViewCell.m
//  Flyy
//
//  Created by Xingxing Xu on 2/15/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTopicDetailTopicCell.h"
#import "FLYIconButton.h"
#import "FLYPlayTimelineView.h"
#import "UIColor+FLYAddition.h"
#import "FLYTopic.h"
#import "FLYUser.h"

@interface FLYTopicDetailTopicCell()

@property (nonatomic) UIView *topicContentView;
@property (nonatomic) UIImageView *speechBubbleView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) FLYIconButton *likeButton;
@property (nonatomic) UILabel *topicTitle;
@property (nonatomic) FLYIconButton *commentButton;
@property (nonatomic) UILabel *postAtLabel;

@property (nonatomic) UIButton *bigPostCommentButton;
@property (nonatomic) UIImageView *lineView;
@property (nonatomic) UIButton *playButton;

@property (nonatomic) BOOL didSetupConstraints;
@property (nonatomic) FLYTopic *topic;

@end

@implementation FLYTopicDetailTopicCell

#define kTopicContentTopPadding 20
#define kTopicContentLeftPadding 15
#define kTopicContentRightPadding 15
#define kUsernameTopPadding 5
#define kUsernameLeftPadding 37
#define kUsernameRightPadding 3
#define kElementRightPadding 10
#define kTopicTitleTopPadding 5
#define kTopicTitleRightPadding 5
#define kCommentTopPadding 5


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [ super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _topicContentView = [UIView new];
        _topicContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_topicContentView];
        
        _speechBubbleView = [UIImageView new];
        _speechBubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage* image = [UIImage imageNamed:@"icon_homefeed_speech_bubble"];
        UIEdgeInsets insets = UIEdgeInsetsMake(40, 40, 70, 50);
        image = [image resizableImageWithCapInsets:insets];
        self.speechBubbleView.image = image;
        [self.topicContentView addSubview:self.speechBubbleView];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.textColor = [UIColor flyBlue];
        //Avenir-Roman
        _userNameLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_userNameLabel];
        
        //shared font
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:14];
        
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyBlue]  icon:@"icon_homefeed_wings" isIconLeft:YES]  ;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_likeButton];
        
        _topicTitle = [UILabel new];
        _topicTitle.numberOfLines = 0;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _userNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _topicTitle.font = [UIFont fontWithName:@"Avenir-Book" size:17];
        _topicTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView insertSubview:self.topicTitle aboveSubview:self.speechBubbleView];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyBlue] icon:@"icon_homefeed_comment" isIconLeft:NO];
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton sizeToFit];
        [self.topicContentView addSubview:_commentButton];
        
        _postAtLabel = [UILabel new];
        _postAtLabel.font = inlineActionFont;
        _postAtLabel.textColor = [UIColor flyFeedGrey];
        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_postAtLabel];
        
        _bigPostCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bigPostCommentButton setImage:[UIImage imageNamed:@"icon_detail_comment"] forState:UIControlStateNormal];
        [_bigPostCommentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _bigPostCommentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_bigPostCommentButton sizeToFit];
        [self.contentView addSubview:_bigPostCommentButton];
        
        _lineView = [UIImageView new];
        _lineView.image = [UIImage imageNamed:@"icon_detail_timeline"];
        [self.contentView addSubview:_lineView];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"icon_detail_playline"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_playButton sizeToFit];
        [self.contentView addSubview:_playButton];
        
    }
    return self;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        float topicCellHeight = [FLYTopicDetailTopicCell heightForTopic:self.topic];
        [self.topicContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kTopicContentTopPadding);
            make.leading.equalTo(self.contentView).offset(kTopicContentLeftPadding);
            make.trailing.equalTo(self.contentView).offset(-kTopicContentRightPadding);
            make.height.equalTo(@(topicCellHeight));
        }];
        
        [self.speechBubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicContentView);
            make.leading.equalTo(self.topicContentView);
            make.trailing.equalTo(self.topicContentView);
            make.bottom.equalTo(self.topicContentView);
        }];
        
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicContentView).offset(kUsernameTopPadding);
            make.leading.equalTo(self.topicContentView).offset(kUsernameLeftPadding);
            make.width.lessThanOrEqualTo(self.topicContentView).offset(kUsernameRightPadding);
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel);
            make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
        }];
        
        [self.topicTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).offset(kTopicTitleTopPadding);
            make.leading.equalTo(self.userNameLabel);
            make.trailing.lessThanOrEqualTo(self.topicContentView).offset(-kElementRightPadding);
        }];
        
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.likeButton);
            make.top.equalTo(self.topicTitle.mas_bottom).offset(kCommentTopPadding);
        }];
        
        [self.postAtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.userNameLabel);
            make.top.equalTo(self.topicTitle.mas_bottom).offset(kCommentTopPadding);
        }];
        
        [self.bigPostCommentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.topicContentView.mas_bottom).offset(-15);
            
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.userNameLabel);
            make.trailing.equalTo(self.speechBubbleView);
            make.top.equalTo(self.bigPostCommentButton.mas_bottom).offset(20);
        }];
        
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.lineView).offset(-self.playButton.bounds.size.width);
            make.centerY.equalTo(self.lineView);
        }];
        
        self.didSetupConstraints = YES;
        
    }
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)setupTopic:(FLYTopic *)topic
{
    self.topic = topic;
    self.userNameLabel.text = topic.user.userName;
    
    self.postAtLabel.text = topic.displayableCreateAt;
    self.topicTitle.text = topic.topicTitle;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topic.topicTitle.length)];
    self.topicTitle.attributedText = attrStr;
    [self.topicTitle sizeToFit];
    
    [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.likeCount]];
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.replyCount]];
}

#pragma mark - Height of the cell
+ (CGFloat)heightForTopic:(FLYTopic *)topic
{
    UILabel *dummyLabel = [UILabel new];
    dummyLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode= NSLineBreakByWordWrapping;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topic.topicTitle.length)];
    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, topic.topicTitle.length)];
    dummyLabel.attributedText = attrStr;
    
    CGFloat rightPadding = kTopicContentRightPadding + kElementRightPadding;
    CGFloat leftPadding = kTopicContentLeftPadding + kUsernameLeftPadding;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - rightPadding - leftPadding;
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //top, bottom
    return rect.size.height + 44 + 50;
}

+ (CGFloat)cellHeightForTopic:(FLYTopic *)topic
{
    float height = 0;
    //top, bottom, padding
    height += [FLYTopicDetailTopicCell heightForTopic:topic] + kTopicContentTopPadding + 100;
    return height;
}

#pragma mark - button taps
- (void)_commentButtonTapped
{
    [self.delegate commentButtonTapped:self];
}

- (void)_likeButtonTapped
{
    
}

- (void)_playButtonTapped
{
    
}

@end
