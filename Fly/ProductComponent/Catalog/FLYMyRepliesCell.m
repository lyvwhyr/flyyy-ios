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
#import "UAProgressView.h"
#import "UIButton+TouchAreaInsets.h"

#define kPlayButtonLeftPadding 16.5
#define kTopicTitleLeftPadding 15
#define kTopicTitleRightPadding 40
#define kUpdateProgressInterval 0.05

@interface FLYMyRepliesCell()

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *topicTitle;
@property (nonatomic) UILabel *postAt;

@property (nonatomic) BOOL didSetupConstraints;

@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

// play progress view
@property (nonatomic) UAProgressView *progressView;
@property (nonatomic) NSTimer *progressTimer;
@property (nonatomic) BOOL paused;
@property (nonatomic) CGFloat timeElapsed;
@property (nonatomic) CGFloat localProgress;
@property (nonatomic) NSArray *progressViewConstraints;
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
        // increase comment button touch area
        _playButton.touchAreaInsets = UIEdgeInsetsMake(10, 40, 10, 10);
        
        _topicTitle = [UILabel new];
        _topicTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _topicTitle.numberOfLines = 1;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _topicTitle.textColor = [FLYUtilities colorWithHexString:@"#676666"];
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
    if (_loadingIndicatorView) {
        [_loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.playButton);
            make.centerY.equalTo(self.playButton);
        }];
    }
    
    [self.playButton sizeToFit];
    if (!self.didSetupConstraints) {
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.width.equalTo(@(CGRectGetWidth(self.playButton.bounds)));
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

- (void)setupCellWithTopic:(FLYTopic *)topic reply:(FLYReply *)reply
{
    self.topic = topic;
    self.reply = reply;
    
    self.topicTitle.text = self.topic.topicTitle;
    self.postAt.text = reply.displayableCreateAt;
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

#pragma mark - progress

- (UAProgressView *)progressView
{
    if (!_progressView) {
        [self _clearProgressView];
        
        _progressView = [[UAProgressView alloc] init];
        _progressView.tintColor = [UIColor flyBlue];
        _progressView.lineWidth = 3;
        _progressView.fillOnTouch = NO;
        _progressView.borderWidth = 0;
        @weakify(self)
        _progressView.didSelectBlock = ^(UAProgressView *progressView){
            @strongify(self)
            [self.delegate playButtonTapped:self withIndexPath:self.indexPath];
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

#pragma mark - inline actions
- (void)_playButtonTapped
{
    [self.delegate playButtonTapped:self withIndexPath:self.indexPath];
}

@end
