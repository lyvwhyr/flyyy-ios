//
//  FLYPrePostChooseGroupTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYGroupListCell : UITableViewCell

@property (nonatomic, copy) NSString *groupName;

@property (nonatomic) UILabel *groupNameLabel;
@property (nonatomic) UIButton *checkButton;
@property (nonatomic) UIView *separator;

- (void)selectCell;

@end
