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

@interface FLYTopicDetailReplyCell()

@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) UILabel *inReplyToUserNameLabel;
@property (nonatomic) FLYReplyPlayView *replyPlayView;
@property (nonatomic) UILabel *postAtLabel;

@property (nonatomic) FLYIconButton *flyButton;
@property (nonatomic) FLYIconButton *commentButton;

@end

@implementation FLYTopicDetailReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _avatarImageView = [UIImageView new];
        NSString *avatarName = [NSString stringWithFormat:@"p%d.jpg", (arc4random()%10 + 1)];
        UIImage *avatarImage = [UIImage imageNamed:avatarName];
        [_avatarImageView setImage:avatarImage];
        [_avatarImageView sizeToFit];
        _avatarImageView.layer.cornerRadius = 18;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_avatarImageView];
        
        _userNameLabel = [UILabel new];
        _userNameLabel.text = @"colorfulmelody";
        _userNameLabel.font = [UIFont systemFontOfSize:14];
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_userNameLabel];
        
        _inReplyToUserNameLabel = [UILabel new];
        _inReplyToUserNameLabel.text = @"@natasha";
        _inReplyToUserNameLabel.font = [UIFont systemFontOfSize:12];
        _inReplyToUserNameLabel.textColor = [UIColor flyFeedGrey];
        _inReplyToUserNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_inReplyToUserNameLabel];
        
        _replyPlayView = [FLYReplyPlayView new];
        _replyPlayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_replyPlayView];
        
        _postAtLabel = [UILabel new];
        _postAtLabel.text = @"3m";
        _postAtLabel.font = [UIFont systemFontOfSize:13];
        _postAtLabel.textColor = [UIColor flyFeedGrey];
        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_postAtLabel];
        
        UIColor *color = [UIColor flyInlineActionGrey];
        UIFont *font = [UIFont systemFontOfSize:13.0f];
        _flyButton = [[FLYIconButton alloc] initWithText:@"Fly" textFont:font textColor:color icon:@"icon_inline_wing" isIconLeft:YES];
        _flyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_flyButton];
        
        _commentButton = [[FLYIconButton alloc] initWithText:@"Comment" textFont:font textColor:color  icon:@"icon_inline_comment" isIconLeft:NO];
//        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_commentButton];
        
        [self needsUpdateConstraints];
    }
    
    return self;
}

- (void)updateConstraints
{
    [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.leading.equalTo(self).offset(20);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.leading.equalTo(_avatarImageView.mas_right).offset(10);
    }];
    
    [_inReplyToUserNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameLabel.mas_bottom).offset(3);
        make.leading.equalTo(_avatarImageView.mas_right).offset(10);
    }];
    
    [_replyPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
        make.width.equalTo(@(75));
        make.height.equalTo((@30));
    }];
    
    [_postAtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-20);
    }];
    
    UIView *helperView = [UIView new];
    [self addSubview:helperView];
    [helperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_userNameLabel.mas_trailing);
        make.trailing.equalTo(_postAtLabel.mas_leading);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    helperView.userInteractionEnabled = NO;
    
    [_replyPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(helperView);
    }];
    

    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
        make.trailing.equalTo(self).offset(-10);
    }];
    
    [_flyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-10);
        make.trailing.equalTo(_commentButton.mas_leading).offset(-40);
    }];

    
    [super updateConstraints];
}


@end
