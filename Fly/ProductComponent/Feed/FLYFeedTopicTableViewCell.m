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
#import "UIImage+FLYAddition.h"
#import "FLYTopic.h"
#import "FLYIconButton.h"
#import "FLYUser.h"
#import "FLYGroup.h"
#import "Dialog.h"
#import "CALayer+MBAnimationPersistence.h"

@interface FLYFeedTopicTableViewCell()

//timeline and play button
@property (nonatomic) UIImageView *timelineImageView;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) CAShapeLayer *arcLayer;
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

@property (nonatomic) BOOL didSetupConstraints;

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
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:14];
        
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyBlue]  icon:@"icon_homefeed_wings" isIconLeft:YES]  ;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.topicContentView addSubview:_likeButton];
        
        _groupNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _groupNameButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_groupNameButton addTarget:self action:@selector(_groupNameTapped) forControlEvents:UIControlEventTouchUpInside];
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
        
        
        //when it enters background, _arclayer is nil so this doesn't work
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pauseLayer) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resumeLayer) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

-(void)drawLineAnimation
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.playButton.bounds),  CGRectGetMidY(self.playButton.bounds));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:18 startAngle: -(float)M_PI_2 endAngle:2 * M_PI clockwise:YES];
    _arcLayer = [CAShapeLayer layer];
    _arcLayer.path = path.CGPath;
    _arcLayer.strokeColor = [UIColor flyColorPlayAnimation].CGColor;
    _arcLayer.fillColor = [UIColor clearColor].CGColor;
    _arcLayer.lineWidth = 3.5;
    [_playButton.layer addSublayer:_arcLayer];
    
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.removedOnCompletion = YES;
    bas.duration = self.topic.audioDuration + self.topic.audioDuration/5;
    bas.delegate = self;
    bas.speed = 1.0;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [_arcLayer addAnimation:bas forKey:@"position"];
    
//    self.arcLayer.MB_persistentAnimationKeys = @[@"position"];
}

-(void)_pauseLayer
{
    if (_arcLayer) {
        CFTimeInterval pausedTime = [_arcLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        _arcLayer.speed = 0.0;
        _arcLayer.timeOffset = pausedTime;
    }
}

-(void)_resumeLayer
{
    if (_arcLayer) {
        CFTimeInterval pausedTime = [_arcLayer timeOffset];
        _arcLayer.speed = 1.0;
        _arcLayer.timeOffset = 0.0;
        _arcLayer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [_arcLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        _arcLayer.beginTime = timeSincePause;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.arcLayer removeFromSuperlayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)updateConstraints
{
    if (_loadingIndicatorView) {
        [_loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.playButton);
            make.centerY.equalTo(self.playButton);
        }];
    }
    
    if (!self.didSetupConstraints) {
        void (^timelineConstraintBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(0);
            make.leading.equalTo(self).offset(kHomeTimeLineLeftPadding);
            make.height.equalTo(self);
        };
        
        CGFloat topicContentLeftPadding = kHomeTimeLineLeftPadding + CGRectGetWidth(_timelineImageView.bounds)/2 + CGRectGetWidth(_playButton.bounds)/2 + kTopicContentLeftPadding;
        void (^topicContentViewConstraintBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(2);
            make.leading.equalTo(self.contentView).offset(topicContentLeftPadding);
            make.trailing.equalTo(self.contentView).offset(-kTopicContentRightPadding);
            make.bottom.equalTo(self.contentView).offset(-kTopicContentBottomPadding);
        };
        
        void (^speechBubbleViewBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicContentView).offset(0);
            make.leading.equalTo(self.topicContentView).offset(0);
            make.trailing.equalTo(self.topicContentView).offset(0);
            make.bottom.equalTo(self.topicContentView).offset(-10);
        };
        
        void (^playButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.timelineImageView);
            make.bottom.equalTo(self.mas_bottom);
        };
        
        void (^userNameLabelBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicContentView).offset(5);
            make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
            make.width.lessThanOrEqualTo(self.topicContentView).offset(kUsernameOffset);
        };
        
        void (^shareButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicContentView).offset(5);
            make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
        };
        
        void (^topicTitleBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.userNameLabel.mas_bottom).offset(5);
            make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
            make.trailing.equalTo(self.topicContentView).offset(-10);
        };
        
        void (^likeButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicTitle.mas_bottom).offset(kInlineActionTopPadding);
            make.leading.equalTo(self.topicContentView).offset(kElementLeftPadding);
        };
        
        void (^groupNameButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.likeButton);
            make.centerX.equalTo(self.speechBubbleView);
        };
        
        void (^commentButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.likeButton);
            make.trailing.equalTo(self.speechBubbleView.mas_trailing).offset(-kElementRightPadding);
        };
        
        [self.timelineImageView mas_makeConstraints:timelineConstraintBlock];
        [self.topicContentView mas_makeConstraints:topicContentViewConstraintBlock];
        [self.speechBubbleView mas_makeConstraints:speechBubbleViewBlock];
        [self.playButton mas_makeConstraints:playButtonBlock];
        [self.userNameLabel mas_makeConstraints:userNameLabelBlock];
        [self.shareButton mas_makeConstraints:shareButtonBlock];
        [self.topicTitle mas_makeConstraints:topicTitleBlock];
        [self.likeButton mas_makeConstraints:likeButtonBlock];
        [self.groupNameButton mas_makeConstraints:groupNameButtonBlock];
        [self.commentButton mas_makeConstraints:commentButtonBlock];
        
        self.didSetupConstraints = YES;
        
    }
    [super updateConstraints];
}

- (UIActivityIndicatorView *)loadingIndicatorView
{
    if (_loadingIndicatorView == nil) {
        _loadingIndicatorView = [UIActivityIndicatorView new];
        _loadingIndicatorView.hidesWhenStopped = YES;
        [self.contentView insertSubview:_loadingIndicatorView aboveSubview:self.playButton];
    }
    [self updateConstraints];
    [_loadingIndicatorView startAnimating];
    return _loadingIndicatorView;
}

#pragma mark - assign values to cell
- (void)setupTopic:(FLYTopic *)topic needUpdateConstraints:(BOOL)needUpdateConstraints
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
    [self.groupNameButton setTitle:[NSString stringWithFormat:@"#%@", topic.group.groupName] forState:UIControlStateNormal];
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.replyCount]];
}

#pragma mark - update play state
- (void)updatePlayState:(FLYPlayState)state
{
    [_loadingIndicatorView stopAnimating];
    switch (state) {
        case FLYPlayStateNotSet: {
            [self.arcLayer removeAllAnimations];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateLoading: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backplay_bg"] forState:UIControlStateNormal];
            [self loadingIndicatorView];
            break;
        }
        case FLYPlayStatePlaying: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            [self drawLineAnimation];
            break;
        }
        case FLYPlayStatePaused: {
            [self _pauseLayer];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateResume: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            [self _resumeLayer];
            break;
        }
        case FLYPlayStateFinished: {
            [self.arcLayer removeFromSuperlayer];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self.arcLayer removeFromSuperlayer];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_backgroundplay"] forState:UIControlStateNormal];
            break;
        }
    }
}

#pragma mark - inline actions
- (void)_playButtonTapped
{
    [self.delegate playButtonTapped:self withPost:self.topic withIndexPath:self.indexPath];
}

- (void)_likeButtonTapped
{
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"" component:self.topic.topicId element:@"like_button" action:@"click"];
    
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}

- (void)_shareButtonTapped
{
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}

- (void)_commentButtonTapped
{
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"" component:self.topic.topicId element:@"comment_button" action:@"click"];
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}

- (void)_groupNameTapped
{
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
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
