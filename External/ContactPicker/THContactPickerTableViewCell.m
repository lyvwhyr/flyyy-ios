//
//  THContactPickerTableViewCell.m
//  ContactPicker
//
//  Created by Mac on 3/27/14.
//  Copyright (c) 2014 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerTableViewCell.h"

@implementation THContactPickerTableViewCell

- (void)updateConstraints
{
//    [self mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self);
//        make.trailing.equalTo(self.)
//    }];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
