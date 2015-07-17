//
//  UITableViewCell+FLYAddition.m
//  Flyy
//
//  Created by Xingxing Xu on 7/16/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "UITableViewCell+FLYAddition.h"

@implementation UITableViewCell (FLYAddition)

- (UIViewController *)tableViewController
{
    UIView *view = self;
    while (!(view == nil || [view isKindOfClass:[UITableView class]])) {
        view = view.superview;
    }
    
    return (UIViewController *)((UITableView *)view).dataSource;
}

@end
