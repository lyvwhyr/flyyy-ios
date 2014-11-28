//
//  FLYFilterSelectorGroupTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYFilterSelectorGroupTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *groupName;

- (void)selectCell;

@end
