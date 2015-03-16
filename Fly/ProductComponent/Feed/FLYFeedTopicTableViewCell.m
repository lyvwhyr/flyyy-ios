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

@interface FLYFeedTopicTableViewCell()

//timeline and play button
@property (nonatomic) UIButton *playButton;
@property (nonatomic) CAShapeLayer *arcLayer;
@property (nonatomic) UIActivityIndicatorView *loadingIndicatorView;

//topic content view
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

#define kPlaybuttonLeftPadding 21
#define kTopicTitleTopPadding  25
#define kTopicTitleLeftPadding 15
#define kTopicTitleRightPadding 130
#define kInlineActionTopPadding 10
#define kInlineActionRightPadding 15
#define kGroupLeftPadding 30

#define kTopicContentRightPadding       10
//padding for user name, topic title to it's parent view
#define kElementRightPadding            10
#define kUsernameOffset                -100

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
        _topicTitle.numberOfLines = 1;
        _topicTitle.adjustsFontSizeToFitWidth = NO;
        _topicTitle.textColor = [UIColor colorWithHexString:@"#676666"];
        _topicTitle.lineBreakMode = NSLineBreakByTruncatingTail;
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
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
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

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_likeUpdated:) name:kNotificationTopicLikeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_replyCountUpdated:) name:kNewReplyPostedNotification object:nil];
    
}

-(void)drawLineAnimation
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.playButton.bounds),  CGRectGetMidY(self.playButton.bounds));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:17 startAngle: -(float)M_PI_2 endAngle:2 * M_PI clockwise:YES];
    _arcLayer = [CAShapeLayer layer];
    _arcLayer.path = path.CGPath;
    _arcLayer.strokeColor = [UIColor flyColorPlayAnimation].CGColor;
    _arcLayer.fillColor = [UIColor clearColor].CGColor;
    _arcLayer.lineWidth = 3;
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
        
        void (^playButtonBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(kPlaybuttonLeftPadding);
            make.centerY.equalTo(self.contentView);
        };
        
        void (^topicTitleBlock)(MASConstraintMaker *make) = ^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kTopicTitleTopPadding);
            make.leading.equalTo(self.playButton.mas_trailing).offset(kTopicTitleLeftPadding);
            make.width.lessThanOrEqualTo(self.contentView).offset(-kTopicTitleRightPadding);
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
        [self.groupNameButton mas_makeConstraints:groupNameButtonBlock];
        [self.userNameLabel mas_makeConstraints:userNameLabelBlock];
        [self.likeButton mas_makeConstraints:likeButtonBlock];
        [self.commentButton mas_makeConstraints:commentButtonBlock];
        
        self.didSetupConstraints = YES;
        
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

#pragma mark - update play state
- (void)updatePlayState:(FLYPlayState)state
{
    [_loadingIndicatorView stopAnimating];
    switch (state) {
        case FLYPlayStateNotSet: {
            [self.arcLayer removeAllAnimations];
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
            [self drawLineAnimation];
            break;
        }
        case FLYPlayStatePaused: {
            [self _pauseLayer];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        case FLYPlayStateResume: {
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_pause"] forState:UIControlStateNormal];
            [self _resumeLayer];
            break;
        }
        case FLYPlayStateFinished: {
            [self.arcLayer removeFromSuperlayer];
            [self.playButton setImage:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] forState:UIControlStateNormal];
            break;
        }
        default: {
            [self.arcLayer removeFromSuperlayer];
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

- (void)_commentButtonTapped
{
    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"" component:self.topic.topicId element:@"comment_button" action:@"click"];
    [Dialog simpleToast:LOC(@"FLYWorkingInProgressHUD")];
}

- (void)_groupNameTapped
{
    [self.delegate groupNameTapped:self indexPath:self.indexPath];
}


#pragma mark - Height of the cell
+ (CGFloat)heightForTopic:(FLYTopic *)topic
{
    return 90;
//    
//    CGFloat height = 0;
//    
//    UILabel *dummyLabel = [UILabel new];
//    dummyLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topic.topicTitle];
//    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
////    paragraphStyle.lineBreakMode= NSLineBreakByTruncatingTail;
//    paragraphStyle.lineSpacing = 2;
//    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, topic.topicTitle.length)];
//    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, topic.topicTitle.length)];
//    dummyLabel.attributedText = attrStr;
//    
//    CGFloat rightPadding = kTopicContentRightPadding + kElementRightPadding;
//    //half 5/2 timeline width, 19.5 = 117/3/ radius for play button
//    CGFloat leftPadding = kElementLeftPadding + 5/2 + 19.5 + kTopicContentLeftPadding + kElementLeftPadding;
//    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - rightPadding - leftPadding;
//    
//    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    
//    
//    //
//    NSString *dummyString = @"dummyText";
//    NSMutableAttributedString *attrStrSingleLine = [[NSMutableAttributedString alloc] initWithString:dummyString];
//    paragraphStyle.lineSpacing = 2;
//    [attrStrSingleLine addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, dummyString.length)];
//    [attrStrSingleLine addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, dummyString.length)];
//    CGRect rectSingleLine = [attrStrSingleLine boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//
//    CGFloat labelHeight = 0.0;
//    int numberOfLines = ceil(rect.size.height / rectSingleLine.size.height);
//    if (numberOfLines >= 2) {
//        labelHeight = rectSingleLine.size.height * 2 + paragraphStyle.lineSpacing;
//    } else {
//        labelHeight = rect.size.height;
//    }
//    //top, bottom, padding
//    height += labelHeight + 44 + 70;
//    
//    return height;
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
