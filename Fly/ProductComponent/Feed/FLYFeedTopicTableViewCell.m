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
#import "FLYTopicService.h"
#import "UIColor+FLYAddition.h"
#import "UIView+FLYAddition.h"
#import "FLYReply.h"
#import "UAProgressView.h"
#import "UIButton+TouchAreaInsets.h"
#import "UIButton+TouchAreaInsets.h"
#import "SDiPhoneVersion.h"
#import "UITableViewCell+FLYAddition.h"
#import "FLYShareManager.h"

@interface FLYFeedTopicTableViewCell() <TTTAttributedLabelDelegate>

@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

@property (nonatomic) FLYIconButton *shareButton;

// play progress view
@property (nonatomic) UAProgressView *progressView;
@property (nonatomic) NSTimer *progressTimer;
@property (nonatomic) BOOL paused;
@property (nonatomic) CGFloat timeElapsed;
@property (nonatomic) CGFloat localProgress;

@property (nonatomic) BOOL didSetupConstraints;
@property (nonatomic, copy) NSString *topicTitleString;

@property (nonatomic) NSArray *progressViewConstraints;

@end

@implementation FLYFeedTopicTableViewCell

#define kPlaybuttonLeftPadding 15
#define kPlayButtonSize 36
#define kTopicTitleTopPadding  20
#define kTopicTitleLeftPadding 15
#define kTopicTitleRightPadding 5
#define kInlineActionTopPadding 10
#define kMaxInlineActionWidth 51
#define kInlineActionRightPadding 10
#define kGroupLeftPadding 30

#define kTopicContentRightPadding       10
//padding for user name, topic title to it's parent view
#define kElementRightPadding            10
#define kUsernameOffset                -100

#define kUpdateProgressInterval 0.05

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
        [_playButton sizeToFit];
        
        _playButton.touchAreaInsets = UIEdgeInsetsMake(kTopicTitleTopPadding - 2, kPlaybuttonLeftPadding, 15, kTopicTitleLeftPadding);
        [self.contentView insertSubview:self.playButton aboveSubview:self.contentView];
        
        _topicTitleLabel = [TTTAttributedLabel new];
        _topicTitleLabel.delegate = self;
        _topicTitleLabel.numberOfLines = 0;
        _topicTitleLabel.adjustsFontSizeToFitWidth = NO;
        _topicTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_topicTitleLabel];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.textColor = [UIColor flyGrey];
        _userNameLabel.font = [UIFont fontWithName:@"Avenir-Book" size:8];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _userNameLabel.adjustsFontSizeToFitWidth = YES;
        _userNameLabel.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_userNameLabel];
        
        UIFont *shareFont = [UIFont fontWithName:@"Avenir-Book" size:10];
        _shareButton = [[FLYIconButton alloc] initWithText:@"share" textFont:shareFont textColor:[UIColor flyShareTextYellow]  icon:@"icon_home_timeline_post_share" isIconLeft:YES]  ;
        [_shareButton addTarget:self action:@selector(_shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        _shareButton.touchAreaInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        [self.contentView addSubview:_shareButton];
        
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:13];
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyInlineAction]  icon:@"icon_homefeed_like" isIconLeft:YES]  ;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_likeButton];
        
        // increase like touch area
        _likeButton.touchAreaInsets = UIEdgeInsetsMake(10, 40, 10, 10);
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyInlineAction] icon:@"icon_homefeed_comment_light" isIconLeft:YES];
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton sizeToFit];
        [self.contentView addSubview:_commentButton];
        _commentButton.touchAreaInsets = UIEdgeInsetsMake(10, 40, 10, 10);
        
        
        //when it enters background, _arclayer is nil so this doesn't work
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pauseLayer) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resumeLayer) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self _addObservers];
    }
    return self;
}

- (UAProgressView *)progressView
{
    if (!_progressView) {
        [self _clearProgressView];
        
        _progressView = [[UAProgressView alloc] init];
        _progressView.tintColor = [UIColor flyColorPlayAnimation];
        _progressView.lineWidth = 3;
        _progressView.fillOnTouch = NO;
        _progressView.borderWidth = 0;
        @weakify(self)
        _progressView.didSelectBlock = ^(UAProgressView *progressView){
            @strongify(self)
            [self.delegate playButtonTapped:self withPost:self.topic withIndexPath:self.indexPath];
            self.paused = !self.paused;
        };
        _progressView.progress = 0;
        _progressView.animationDuration = self.topic.audioDuration;
        [self addSubview:_progressView];
        
        // We need to run the timer in runloop because the timer will be paused while scrolling or touch event
        _progressTimer = [NSTimer timerWithTimeInterval:kUpdateProgressInterval target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    return _progressView;
}

- (void)_clearProgressView
{
    [_progressTimer invalidate];
    _progressTimer = nil;
    
    _timeElapsed = 0;
    _paused = NO;
    _progressViewConstraints = nil;
    [_progressView removeFromSuperview];
    _progressView = nil;
}

- (void)updateProgress:(NSTimer *)timer {
    if (_timeElapsed >= self.topic.audioDuration) {
        [_progressView removeFromSuperview];
        _progressView = nil;
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
    if (!_paused) {
        _timeElapsed += kUpdateProgressInterval;
        _localProgress = _timeElapsed / self.topic.audioDuration;
        [_progressView setProgress:_localProgress];
        [self updateConstraints];
    }
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_likeUpdated:) name:kNotificationTopicLikeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_replyCountUpdated:) name:kNewReplyPostedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_replyCountUpdated:) name:kNewReplyDeletedNotification object:nil];
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
        
        void (^playButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(kPlaybuttonLeftPadding);
            make.centerY.equalTo(self.contentView);
        };
        
        
        CGFloat leftPadding = kPlaybuttonLeftPadding + kPlayButtonSize + kTopicTitleLeftPadding;
        CGFloat rightPadding = kInlineActionRightPadding + kMaxInlineActionWidth + kTopicTitleRightPadding;
        void (^topicTitleBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kTopicTitleTopPadding);
            make.leading.equalTo(self.playButton.mas_trailing).offset(kTopicTitleLeftPadding);
            make.width.lessThanOrEqualTo(self.contentView).offset(-leftPadding-rightPadding);
        };
        
        
        void (^userNameLabelBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicTitleLabel.mas_bottom).offset(10);
            make.leading.equalTo(self.topicTitleLabel);
            make.trailing.lessThanOrEqualTo(self.topicTitleLabel.mas_centerX).offset(-25);
        };

        void (^likeButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kInlineActionTopPadding);
            make.trailing.equalTo(self.contentView).offset(-kInlineActionRightPadding);
        };
        
        void (^commentButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-kInlineActionTopPadding);
            make.trailing.equalTo(self.contentView).offset(-kInlineActionRightPadding);
        };
        
        void (^shareButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.userNameLabel);
            make.leading.equalTo(self.userNameLabel.mas_trailing).offset(kGroupLeftPadding);
            make.trailing.lessThanOrEqualTo(self.topicTitleLabel.mas_trailing);
            make.width.lessThanOrEqualTo(@(CGRectGetWidth(self.bounds)/4));
        };
        
        [self.playButton mas_makeConstraints:playButtonBlock];
        [self.topicTitleLabel mas_makeConstraints:topicTitleBlock];
        [self.userNameLabel mas_makeConstraints:userNameLabelBlock];
        [self.likeButton mas_makeConstraints:likeButtonBlock];
        [self.commentButton mas_makeConstraints:commentButtonBlock];
        [self.shareButton mas_makeConstraints:shareButtonBlock];
        
        self.didSetupConstraints = YES;
    }
    if (_progressView  && !_progressViewConstraints) {
        _progressViewConstraints = [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.playButton);
            make.width.equalTo(self.playButton).offset(-1.5);
            make.height.equalTo(self.playButton).offset(-1.5);
        }];
    }
    [super updateConstraints];
}

- (UIActivityIndicatorView *)loadingIndicatorView
{
    if (_loadingIndicatorView == nil) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    if (topic.topicTitle.length == 0) {
        return;
    }
    
    self.topic = topic;
    self.userNameLabel.text = [NSString stringWithFormat:@"by %@", topic.user.userName];

    
    self.topicTitleLabel.linkAttributes = @{NSForegroundColorAttributeName:[UIColor flyHomefeedBlue]};
    self.topicTitleLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor flyHomefeedBlue]};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[FLYFeedTopicTableViewCell _getDisplayTitleString:topic]];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [FLYFeedTopicTableViewCell _getDisplayTitleString:topic].length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, [FLYFeedTopicTableViewCell _getDisplayTitleString:topic].length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor flyTopicTitleColor] range:NSMakeRange(0, [FLYFeedTopicTableViewCell _getDisplayTitleString:topic].length)];
    
    self.topicTitleLabel.attributedText = attrStr;
    
    // add hashTags
    for (FLYGroup *tag in self.topic.tags) {
        NSRange range = [[self.topicTitleLabel.text lowercaseString] rangeOfString:[NSString stringWithFormat:@"#%@", [tag.groupName lowercaseString]] options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            [self.topicTitleLabel addLinkToURL:[NSURL URLWithString:tag.groupId] withRange:range];
        }
    }
    
    [self.topicTitleLabel sizeToFit];
    
    if (self.topic.liked) {
        [self setLiked:YES animated:NO];
    } else {
        [self setLiked:NO animated:NO];
    }
    
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.replyCount]];
}

- (void)setLiked:(BOOL)liked animated:(BOOL)animated
{
    if (liked) {
        if (animated) {
            [self.likeButton enlargeAnimation];
        }
        
        [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)self.topic.likeCount]];
        [self.likeButton setLabelTextColor:[UIColor flyHomefeedBlue]];
        UIImage *image = [[UIImage imageNamed:@"icon_homefeed_like"] imageWithColorOverlay:[UIColor flyHomefeedBlue]];
        [self.likeButton setIconImage:image];
    } else {
        [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)self.topic.likeCount]];
        [self.likeButton setLabelTextColor:[UIColor flyInlineAction]];
        UIImage *image = [UIImage imageNamed:@"icon_homefeed_like"];
        [self.likeButton setIconImage:image];
    }
}

- (void)_updateReplyCount:(NSInteger)replyCount
{
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)replyCount]];
}

#pragma mark - update play state. After user action, play state.
- (void)updatePlayState:(FLYPlayState)state
{
    [_loadingIndicatorView stopAnimating];
    switch (state) {
        case FLYPlayStateNotSet: {
            [self _clearProgressView];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateLoading: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            [self loadingIndicatorView];
            break;
        }
        case FLYPlayStatePlaying: {
            [[FLYScribe sharedInstance] logEvent:@"play" section:@"topic" component:nil element:nil action:nil];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            [self progressView];
            break;
        }
        case FLYPlayStatePaused: {
            [[FLYScribe sharedInstance] logEvent:@"pause" section:@"topic" component:nil element:nil action:nil];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateResume: {
            [[FLYScribe sharedInstance] logEvent:@"resume" section:@"topic" component:nil element:nil action:nil];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateFinished: {
            [[FLYScribe sharedInstance] logEvent:@"finish_listening" section:@"topic" component:nil element:nil action:nil];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self _clearProgressView];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
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
    if ([FLYUtilities isInvalidUser]) {
        return;
    }
    
    [[FLYScribe sharedInstance] logEvent:@"like" section:@"topic" component:nil element:nil action:nil];
    
    [self.topic like];
}

- (void)_commentButtonTapped
{
    [self.delegate commentButtonTapped:self];
}

- (void)_shareButtonTapped
{
    UIViewController *fromViewController = self.tableViewController;
    [FLYShareManager shareTopicWithTopic:self.topic fromViewController:fromViewController];
}


#pragma mark - Height of the cell
+ (CGFloat)heightForTopic:(FLYTopic *)topic
{
    if (topic.topicTitle.length == 0) {
        return 0;
    }
    NSString *topicTitleDisplayStr = [FLYFeedTopicTableViewCell _getDisplayTitleString:topic];
    
    CGFloat leftPadding = kPlaybuttonLeftPadding + kPlayButtonSize + kTopicTitleLeftPadding;
    CGFloat rightPadding = kInlineActionRightPadding + kMaxInlineActionWidth + kTopicTitleRightPadding;
    CGFloat height = 0;
    UILabel *dummyLabel = [UILabel new];
    dummyLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topicTitleDisplayStr];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topicTitleDisplayStr.length)];
    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, topicTitleDisplayStr.length)];
    dummyLabel.attributedText = attrStr;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - rightPadding - leftPadding;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //top, bottom, padding
    height += rect.size.height + 20 + 40;
    
    return height;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[FLYScribe sharedInstance] logEvent:@"feed" section:@"group_name" component:nil element:nil action:@"click"];
    [self.delegate groupNameTapped:self indexPath:self.indexPath tagId:[url absoluteString]];
}

#pragma mark - notification
- (void)_likeUpdated:(NSNotification *)notif
{
    FLYTopic *topic = [notif.userInfo objectForKey:@"topic"];
    if (!topic || ![topic.topicId isEqualToString:self.topic.topicId]) {
        return;
    }
    [self setLiked:topic.liked animated:YES];
}

- (void)_replyCountUpdated:(NSNotification *)notif
{
    FLYTopic *topic = [notif.userInfo objectForKey:kTopicOfNewReplyKey];
    if (!topic || ![self.topic.topicId isEqualToString:topic.topicId]) {
        return;
    }
    [self _updateReplyCount:topic.replyCount];
}

+ (NSString *)_getDisplayTitleString:(FLYTopic *)topic
{
    NSString *topicTitleDisplayStr;
    if (!topic.tags.count || topic.tags.count > 1) {
        topicTitleDisplayStr = topic.topicTitle;
    } else {
        NSString *tagName = ((FLYGroup *)topic.tags[0]).groupName;
        // old posts
        if ([topic.topicTitle rangeOfString:tagName].location == NSNotFound) {
            topicTitleDisplayStr = [NSString stringWithFormat:@"%@ %@", topic.topicTitle, [NSString stringWithFormat:@"#%@", tagName]];
        } else {
            topicTitleDisplayStr = topic.topicTitle;
        }
    }
    return topicTitleDisplayStr;
}

@end
