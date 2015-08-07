//
//  FLYNotificationTableViewCell.h
//  Flyy
//
//  Created by Xingxing Xu on 8/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYNotification;

@interface FLYNotificationTableViewCell : UITableViewCell

- (void)setupCell:(FLYNotification *)notification;
+ (CGFloat)heightForNotification:(FLYNotification *)notification;

@end
