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

@interface FLYFeedTopicTableViewCell()

//timeline and play button
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

//topic content view
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) UILabel *topicTitle;
@property (nonatomic) FLYIconButton *likeButton;
@property (nonatomic) UIButton *groupNameButton;
@property (nonatomic) FLYIconButton *commentButton;

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
        [self.contentView insertSubview:self.playButton aboveSubview:self.contentView];
        
        _topicTitle = [UILabel new];
        _topicTitle.numberOfLines = 0;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _topicTitle.textColor = [UIColor colorWithHexString:@"#676666"];
        _topicTitle.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
        _topicTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_topicTitle];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.textColor = [UIColor flyGrey];
        _userNameLabel.font = [UIFont fontWithName:@"Avenir-Book" size:8];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_userNameLabel];
        
        _groupNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _groupNameButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_groupNameButton addTarget:self action:@selector(_groupNameTapped) forControlEvents:UIControlEventTouchUpInside];
        _groupNameButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13];
        [_groupNameButton setTitleColor:[UIColor flyHomefeedBlue] forState:UIControlStateNormal];
        _groupNameButton.titleEdgeInsets = UIEdgeInsetsZero;
        [_groupNameButton sizeToFit];
        [self.contentView addSubview:_groupNameButton];
        
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:13];
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyInlineAction]  icon:@"icon_homefeed_like" isIconLeft:YES]  ;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_likeButton];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:[UIColor flyInlineAction] icon:@"icon_homefeed_comment_light" isIconLeft:YES];
        _commentButton.userInteractionEnabled = NO;
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton sizeToFit];
        [self.contentView addSubview:_commentButton];
        
        
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
            make.top.equalTo(self.topicTitle.mas_bottom).offset(10);
            make.leading.equalTo(self.topicTitle);
//            make.width.lessThanOrEqualTo(self.topicContentView).offset(kUsernameOffset);
        };

        void (^likeButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kInlineActionTopPadding);
            make.trailing.equalTo(self.contentView).offset(-kInlineActionRightPadding);
        };
        
        void (^commentButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-kInlineActionTopPadding);
            make.trailing.equalTo(self.likeButton);
        };
        
        void (^groupNameButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.userNameLabel);
            make.leading.equalTo(self.userNameLabel.mas_trailing).offset(kGroupLeftPadding);
        };
        
        [self.playButton mas_makeConstraints:playButtonBlock];
        [self.topicTitle mas_makeConstraints:topicTitleBlock];
        if (self.groupNameButton) {
            [self.groupNameButton mas_makeConstraints:groupNameButtonBlock];
        }
        [self.userNameLabel mas_makeConstraints:userNameLabelBlock];
        [self.likeButton mas_makeConstraints:likeButtonBlock];
        [self.commentButton mas_makeConstraints:commentButtonBlock];
        
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
    self.topic = topic;
    self.userNameLabel.text = [NSString stringWithFormat:@"by %@", topic.user.userName];
    
    self.topicTitle.text = topic.topicTitle;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _topicTitleString.length)];
    self.topicTitle.attributedText = attrStr;
    [self.topicTitle sizeToFit];
    
    if (self.topic.liked) {
        [self setLiked:YES animated:NO];
    } else {
        [self setLiked:NO animated:NO];
    }
    
    [self.groupNameButton setTitle:[NSString stringWithFormat:@"#%@", topic.group.groupName] forState:UIControlStateNormal];
    [self.commentButton setLabelText:[NSString stringWithFormat:@"%d", (int)topic.replyCount]];
    
    if (self.options & FLYTopicCellOptionGroupName) {
        [self.groupNameButton removeFromSuperview];
        self.groupNameButton = nil;
    }
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
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            [self progressView];
            break;
        }
        case FLYPlayStatePaused: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateResume: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateFinished: {
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
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"" component:self.topic.topicId element:@"like_button" action:@"click"];
    
    [self.topic like];
}

- (void)_shareButtonTapped
{
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}


- (void)_groupNameTapped
{
    [self.delegate groupNameTapped:self indexPath:self.indexPath];
}


#pragma mark - Height of the cell
+ (CGFloat)heightForTopic:(FLYTopic *)topic
{
    CGFloat leftPadding = kPlaybuttonLeftPadding + kPlayButtonSize + kTopicTitleLeftPadding;
    CGFloat rightPadding = kInlineActionRightPadding + kMaxInlineActionWidth + kTopicTitleRightPadding;
    CGFloat height = 0;
    UILabel *dummyLabel = [UILabel new];
    dummyLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topic.topicTitle.length)];
    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, topic.topicTitle.length)];
    dummyLabel.attributedText = attrStr;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - rightPadding - leftPadding;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //top, bottom, padding
    height += rect.size.height + 20 + 40;
    
    return height;
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

@end
