//
//  FLYPrePostChooseGroupTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYGroup.h"

@interface FLYTagListCell : UITableViewCell

@property (nonatomic) FLYGroup *group;

@property (nonatomic) UILabel *groupNameLabel;
@property (nonatomic) UIButton *checkButton;
@property (nonatomic) UIView *separator;
@property (nonatomic) BOOL isFirst;

- (void)selectCell;

@end
