//
//  FLYPrePostChooseGroupTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostChooseGroupTableViewCell.h"

@interface FLYPrePostChooseGroupTableViewCell()

@property (nonatomic) UILabel *groupNameLabel;
@property (nonatomic) UIButton *checkButton;

@end

@implementation FLYPrePostChooseGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _groupNameLabel = [UILabel new];
        _groupNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _groupNameLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:_groupNameLabel];
        
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.translatesAutoresizingMaskIntoConstraints = NO;
        _checkButton.userInteractionEnabled = NO;
        //        [_checkButton addTarget:self action:@selector(_checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_checkButton setImage:[UIImage imageNamed:@"icon_unchecked"] forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"icon_checked"] forState:UIControlStateHighlighted];
        [_checkButton setImage:[UIImage imageNamed:@"icon_checked"] forState:UIControlStateSelected];
        [_checkButton sizeToFit];
        [self addSubview:_checkButton];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)selectCell
{
    _checkButton.selected = !_checkButton.selected;
}

- (void)setGroupName:(NSString *)groupName
{
    self.groupNameLabel.text = groupName;
}

- (void)updateConstraints
{
    [_groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.top.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
    }];
    
    [_checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.top.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-20);
    }];
    [super updateConstraints];
}

@end
