//
//  FLYRecordBottomBar.m
//  Fly
//
//  Created by Xingxing Xu on 2/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYRecordBottomBar.h"
#import "UIColor+FLYAddition.h"

@interface FLYRecordBottomBar()

@property (nonatomic) UIButton *trashButton;
@property (nonatomic) UIButton *nextButton;

@end

@implementation FLYRecordBottomBar

#define kTrashButtonLeftPadding     20
#define kNextButtonRightPadding     30

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor flyBlue];
        
        _trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_trashButton setImage:[UIImage imageNamed:@"icon_record_trash"] forState:UIControlStateNormal];
        [_trashButton addTarget:self action:@selector(_trashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_trashButton];
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"icon_record_next"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(_nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
    }
    return self;
}

- (void)updateConstraints
{
    [self.trashButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kTrashButtonLeftPadding);
        make.centerY.equalTo(self);
    }];
    
    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-kNextButtonRightPadding);
        make.centerY.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)_trashButtonTapped:(UIButton *)button
{
    [self.delegate trashButtonTapped:button];
}

- (void)_nextButtonTapped:(UIButton *)button
{
    [self.delegate nextButtonTapped:button];
}

@end
