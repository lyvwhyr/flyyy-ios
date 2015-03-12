//
//  FLYTopicDetailTabbar.m
//  Flyy
//
//  Created by Xingxing Xu on 3/9/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTopicDetailTabbar.h"
#import "FLYIconButton.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

@interface FLYTopicDetailTabbar()

@property (nonatomic) FLYIconButton *commentButton;
@property (nonatomic) FLYIconButton *playAllButton;
@property (nonatomic) UIView *separatorView;

@property (nonatomic) UIView *invisibleLeftView;
@property (nonatomic) UIView *invisibleRightView;

@end

@implementation FLYTopicDetailTabbar

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor flyBlue];
        
        _invisibleLeftView = [UIView new];
        _invisibleLeftView.backgroundColor = [UIColor clearColor];
        [self addSubview:_invisibleLeftView];
        
        _invisibleRightView = [UIView new];
        _invisibleRightView.backgroundColor = [UIColor clearColor];
        [self addSubview:_invisibleRightView];
        
        UIFont *font = [UIFont flyFontWithSize:16];
        _commentButton = [[FLYIconButton alloc] initWithText:LOC(@"FLYTopicDetailTabbarComment") textFont:font textColor:[UIColor whiteColor] icon:@"icon_tabbar_detail_comment" isIconLeft:YES];
        [_commentButton addTarget:self action:@selector(_commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_commentButton];
        
        _playAllButton = [[FLYIconButton alloc] initWithText:LOC(@"FLYTopicDetailTabbarPlayAll") textFont:font textColor:[UIColor whiteColor] icon:@"icon_tabbar_detail_playall" isIconLeft:YES];
        [_playAllButton addTarget:self action:@selector(_playAllButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _playAllButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_playAllButton];
        
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)updateConstraints
{
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@([FLYUtilities hairlineHeight]));
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.invisibleLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.top.equalTo(self);
        make.trailing.equalTo(self.separatorView.mas_leading);
        make.bottom.equalTo(self);
    }];
    
    [self.invisibleRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.separatorView.mas_trailing);
        make.top.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.invisibleLeftView);
        make.centerX.equalTo(self.invisibleLeftView);
    }];
    
    [self.playAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.invisibleRightView);
        make.centerX.equalTo(self.invisibleRightView);
    }];
    
    [super updateConstraints];
}

- (void)_commentButtonTapped
{
    [self.delegate commentButtonOnTabbarTapped:self.commentButton];
}

- (void)_playAllButtonTapped
{
    [self.delegate playAllButtonOnTabbarTapped:self.playAllButton];
}

@end
