//
//  FLYReplyTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/7/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYReplyTableViewCell.h"
#import "UIColor+FLYAddition.h"
#import "FLYReplyPlayView.h"

@interface FLYReplyTableViewCell()

@property (nonatomic) UIImageView *avatarImageView;
@property (nonatomic) UILabel *userNameLabel;
@property (nonatomic) FLYReplyPlayView *replyPlayView;
@property (nonatomic) UILabel *postAtLabel;

@end

@implementation FLYReplyTableViewCell

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
        
        _replyPlayView = [FLYReplyPlayView new];
        _replyPlayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_replyPlayView];
        
        _postAtLabel = [UILabel new];
        _postAtLabel.text = @"3m";
        _postAtLabel.font = [UIFont systemFontOfSize:13];
        _postAtLabel.textColor = [UIColor flyFeedGrey];
        _postAtLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_postAtLabel];
        
        [self needsUpdateConstraints];
    }
    
    return self;
}

- (void)updateConstraints
{
    [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(20);
        make.width.equalTo(@(36));
        make.height.equalTo(@(36));
    }];
    
    [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(_avatarImageView.mas_right).offset(10);
    }];
    
    [_replyPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
//        make.leading.equalTo(_userNameLabel.mas_trailing).offset(15);
        make.width.equalTo(@(75));
        make.height.equalTo((@30));
    }];
    
    [_postAtLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
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
    
    [super updateConstraints];
}


@end
