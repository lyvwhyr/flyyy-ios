//
//  FLYPrePostChooseGroupTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupListCell.h"
#import "UIColor+FLYAddition.h"

@implementation FLYGroupListCell

#define kLeftPadding 20
#define kRightPadding 20
#define kSeparatorRightPadding 10

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _groupNameLabel = [UILabel new];
        _groupNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _groupNameLabel.textColor = [UIColor flyColorFlyGroupNameGrey];
        [_groupNameLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        [self addSubview:_groupNameLabel];
        
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.translatesAutoresizingMaskIntoConstraints = NO;
        _checkButton.userInteractionEnabled = NO;
        [_checkButton setImage:[UIImage imageNamed:@"icon_record_empty"] forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"icon_record_checked"] forState:UIControlStateHighlighted];
        [_checkButton setImage:[UIImage imageNamed:@"icon_record_checked"] forState:UIControlStateSelected];
        [_checkButton sizeToFit];
        [self addSubview:_checkButton];
        
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor flyColorFlySelectGroupGrey];
        _separator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_separator];
        
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
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(kLeftPadding);
    }];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kRightPadding);
    }];
    
    CGFloat height = 1.0/[FLYUtilities FLYMainScreenScale];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.equalTo(self).offset(kLeftPadding);
        make.trailing.equalTo(self).offset(-kSeparatorRightPadding);
        make.height.equalTo(@(height));
    }];
    
    [super updateConstraints];
}

@end
