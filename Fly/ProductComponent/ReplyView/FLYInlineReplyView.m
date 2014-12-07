//
//  FLYInlineReplyView.m
//  Fly
//
//  Created by Xingxing Xu on 12/6/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYInlineReplyView.h"
#import "GBFlatButton.h"
#import "UIColor+FLYAddition.h"
#import "FLYCircleView.h"
#import "UIImage+FLYAddition.h"
#import "UIImage+ResizeMagick.h"

#define kInnerCircleRadius  60

@interface FLYInlineReplyView()

@property (nonatomic) UIView *mainView;
@property (nonatomic) GBFlatButton *cancelButton;
@property (nonatomic) GBFlatButton *postButton;
@property (nonatomic) UIView *separatorView;
@property (nonatomic) FLYCircleView *innerCircleView;
@property (nonatomic) UIImageView *micImageView;
@property (nonatomic) UIImageView *trashImageView;

@end

@implementation FLYInlineReplyView

- (instancetype)init
{
    if (self = [super init]) {
        _backgroundView = [UIView new];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *backgroundTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_cancelTapped)];
        [_backgroundView addGestureRecognizer:backgroundTapGR];
        [self addSubview:_backgroundView];
        
        _mainView = [UIView new];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _cancelButton = [GBFlatButton new];
        _cancelButton.tintColor = [UIColor flyInlineActionGrey];
        _cancelButton.buttonTextColor = [UIColor flyInlineActionGrey];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton addTarget:self action:@selector(_cancelTapped) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:_cancelButton];
        
        _postButton = [GBFlatButton new];
        _postButton.tintColor = [UIColor flyInlineActionGrey];
        _postButton.buttonTextColor = [UIColor flyInlineActionGrey];
        [_postButton setTitle:@"Post" forState:UIControlStateNormal];
        _postButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_mainView addSubview:_postButton];
        
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor flyTabBarSeparator];
        _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [_mainView addSubview:_separatorView];
        
        _innerCircleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kInnerCircleRadius, kInnerCircleRadius) radius:kInnerCircleRadius color:[UIColor flyGreen]];
        _innerCircleView.translatesAutoresizingMaskIntoConstraints = NO;
        [_mainView addSubview:_innerCircleView];
        
        _micImageView = [UIImageView new];
        UIImage *image = [UIImage imageNamed:@"icon_reply_record"];
        [_micImageView setImage:image];
        _micImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_mainView addSubview:_micImageView];
        
        _trashImageView = [UIImageView new];
        UIImage *trashImage = [UIImage imageNamed:@"icon_record_trash_bin"];
        [_trashImageView setImage:trashImage];
        _trashImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_mainView addSubview:_trashImageView];
        
        [self addSubview:_mainView];
    }
    return self;
}

- (void)updateConstraints
{
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(CGRectGetHeight([UIScreen mainScreen].bounds) - 200);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(10));
        make.leading.equalTo(@(10));
    }];
    
    [_postButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(10));
        make.trailing.equalTo(@(-20));
    }];
    
    CGFloat height = 1.0/[FLYUtilities FLYMainScreenScale];
    [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@44);
        make.left.equalTo(@0.0);
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo([NSNumber numberWithFloat:height]);
    }];
    
    [_innerCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kInnerCircleRadius * 2));
        make.height.equalTo(@(kInnerCircleRadius * 2));
        make.centerX.equalTo(_mainView);
        make.centerY.equalTo(_mainView).offset(44/2);
    }];
    
    [_micImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_innerCircleView);
    }];
    
    [_trashImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_mainView).offset(-20);
        make.centerY.equalTo(_micImageView);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)_cancelTapped
{
    _backgroudTappedBlock(self);
}

@end
