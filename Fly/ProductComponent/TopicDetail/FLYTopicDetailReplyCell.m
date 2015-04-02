//
//  FLYReplyTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTopicDetailReplyCell.h"
#import "UIColor+FLYAddition.h"
#import "FLYReplyPlayView.h"
#import "FLYIconButton.h"
#import "FLYReply.h"
#import "FLYUser.h"
#import "Dialog.h"
#import "UIView+FLYAddition.h"
#import "UIImage+FLYAddition.h"
#import "UAProgressView.h"

#define kUpdateProgressInterval 0.05

@interface FLYTopicDetailReplyCell()

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *bodyLabel;
@property (nonatomic) UILabel *postAt;
@property (nonatomic) FLYIconButton *likeButton;
@property (nonatomic) UIButton *commentButton;

@property (nonatomic) BOOL didSetupConstraints;


// play progress view
@property (nonatomic) UAProgressView *progressView;
@property (nonatomic) NSTimer *progressTimer;
@property (nonatomic) BOOL paused;
@property (nonatomic) CGFloat timeElapsed;
@property (nonatomic) CGFloat localProgress;
@property (nonatomic) NSArray *progressViewConstraints;


@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

@end

@implementation FLYTopicDetailReplyCell

#define kPlayButtonLeftPadding 24
#define kLikeTopPadding 8
#define kLikeRightPadding 15
#define kCommentBottomPadding 8
#define kBodyLabelYOffset 10
#define kBodyLabelLeftPadding 20
#define kPostAtTopPadding 7

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIColor *color = [UIColor flyInlineActionGrey];
        UIFont *inlineActionFont = [UIFont fontWithName:@"Avenir-Book" size:13];
        _likeButton = [[FLYIconButton alloc] initWithText:@"0" textFont:inlineActionFont textColor:color icon:@"icon_homefeed_like" isIconLeft:YES];
        _likeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_likeButton addTarget:self action:@selector(_likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likeButton];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(_playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playButton];
        
        _bodyLabel = [UILabel new];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14];
        _bodyLabel.textColor = [UIColor flyColorFlyReplyBodyTextGrey];
        [self.contentView addSubview:_bodyLabel];
        
        _postAt = [UILabel new];
        _postAt.translatesAutoresizingMaskIntoConstraints = NO;
        _postAt.font = [UIFont fontWithName:@"Avenir-Book" size:9];
        _postAt.textColor = [UIColor flyColorFlyReplyPostAtGrey];
        [self.contentView addSubview:_postAt];
        
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_commentButton setImage:[UIImage imageNamed:@"icon_homefeed_comment_light"] forState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_commentButton];
        
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
            [self.delegate playButtonTapped:self withReply:self.reply withIndexPath:self.indexPath];
            self.paused = !self.paused;
        };
        _progressView.progress = 0;
        _progressView.animationDuration = self.reply.audioDuration;
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
    if (_timeElapsed >= self.reply.audioDuration) {
        [_progressView removeFromSuperview];
        _progressView = nil;
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
    if (!_paused) {
        _timeElapsed += kUpdateProgressInterval;
        _localProgress = _timeElapsed / self.reply.audioDuration;
        [_progressView setProgress:_localProgress];
        [self updateConstraints];
    }
}

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_likeUpdated:) name:kNotificationReplyLikeChanged object:nil];
}

- (void)setupReply:(FLYReply *)reply
{
    self.reply = reply;
    if (reply.parentReplyUser.userId != nil && ![reply.parentReplyUser.userId isEqualToString:reply.user.userId]) {
        self.bodyLabel.text = [NSString stringWithFormat:@"%@ replied to %@", reply.user.userName, reply.parentReplyUser.userName];
    } else {
        self.bodyLabel.text = [NSString stringWithFormat:@"by %@", reply.user.userName];
    }
    self.postAt.text = reply.displayableCreateAt;
    
    //set like
    [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)reply.likeCount]];
    if (self.reply.liked) {
        [self setLiked:YES animated:NO];
    } else {
        [self setLiked:NO animated:NO];
    }
}

- (void)setLiked:(BOOL)liked animated:(BOOL)animated
{
    if (liked) {
        if (animated) {
            [self.likeButton enlargeAnimation];
        }
        
        [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)self.reply.likeCount]];
        [self.likeButton setLabelTextColor:[UIColor flyHomefeedBlue]];
        UIImage *image = [[UIImage imageNamed:@"icon_homefeed_like"] imageWithColorOverlay:[UIColor flyHomefeedBlue]];
        [self.likeButton setIconImage:image];
    } else {
        [self.likeButton setLabelText:[NSString stringWithFormat:@"%d", (int)self.reply.likeCount]];
        [self.likeButton setLabelTextColor:[UIColor flyInlineAction]];
        UIImage *image = [UIImage imageNamed:@"icon_homefeed_like"];
        [self.likeButton setIconImage:image];
    }
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints) {
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(kPlayButtonLeftPadding);
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kLikeTopPadding);
            make.trailing.equalTo(self).offset(-kLikeRightPadding);
        }];
        
        [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.likeButton);
            make.bottom.equalTo(self).offset(-kCommentBottomPadding);
        }];
        
        [self.bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-kBodyLabelYOffset);
            make.leading.equalTo(self.playButton.mas_trailing).offset(kBodyLabelLeftPadding);
        }];
        
        [self.postAt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bodyLabel);
            make.top.equalTo(self.bodyLabel.mas_bottom).offset(kPostAtTopPadding);
        }];
        
        if (_progressView  && !_progressViewConstraints) {
            _progressViewConstraints = [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.playButton);
                make.width.equalTo(self.playButton).offset(-1.5);
                make.height.equalTo(self.playButton).offset(-1.5);
            }];
        }
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

#pragma mark - notification
- (void)_likeUpdated:(NSNotification *)notif
{
    FLYReply *reply = [notif.userInfo objectForKey:@"reply"];
    if (!reply || ![reply.replyId isEqualToString:self.reply.replyId]) {
        return;
    }
    [self setLiked:reply.liked animated:YES];
}

#pragma mark - User interactions
- (void)_playButtonTapped
{
    [[FLYScribe sharedInstance] logEvent:@"topic_detail" section:@"reply_cell" component:self.reply.replyId element:@"play_button" action:@"click"];
        [self.delegate playButtonTapped:self withReply:self.reply withIndexPath:self.indexPath];
}

- (void)_likeButtonTapped
{
    [self.reply like];
}

- (void)_commentButtonTapped
{
    [[FLYScribe sharedInstance] logEvent:@"topic_detail" section:@"reply_cell" component:self.reply.replyId element:@"like_button" action:@"click"];
    [self.delegate replyToReplyButtonTapped:self.reply];
}

#pragma mark - update play state. After user action, play state.
- (void)updatePlayState:(FLYPlayState)state
{
    [_loadingIndicatorView stopAnimating];
    switch (state) {
        case FLYPlayStateNotSet: {
            [self _clearProgressView];
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateLoading: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
            [self loadingIndicatorView];
            break;
        }
        case FLYPlayStatePlaying: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_pause"] forState:UIControlStateNormal];
            [self progressView];
            break;
        }
        case FLYPlayStatePaused: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateResume: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_pause"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateFinished: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self _clearProgressView];
            [self.playButton setImage:[UIImage imageNamed:@"icon_reply_play_play"] forState:UIControlStateNormal];
            break;
        }
    }
}

@end
