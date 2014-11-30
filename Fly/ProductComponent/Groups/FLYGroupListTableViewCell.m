//
//  FLYGroupTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 11/30/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupListTableViewCell.h"

@interface FLYGroupListTableViewCell()

@property (nonatomic) UILabel *groupNameLabel;

@end

@implementation FLYGroupListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _groupNameLabel = [UILabel new];
        _groupNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _groupNameLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:_groupNameLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setGroupName:(NSString *)groupName
{
    self.groupNameLabel.text = groupName;
}

- (void)updateConstraints
{
    [_groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
    }];
    
    [super updateConstraints];
}

@end
