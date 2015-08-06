//
//  FLYNotificationTableViewCell.m
//  Flyy
//
//  Created by Xingxing Xu on 8/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYNotificationTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "UIColor+FLYAddition.h"

@interface FLYNotificationTableViewCell()

@property (nonatomic) TTTAttributedLabel *activityLabel;

@end

@implementation FLYNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _activityLabel = [TTTAttributedLabel new];
        _activityLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14];
        _activityLabel.textColor = [UIColor flyBlue];
        [self.contentView addSubview:_activityLabel];
    }
    return self;
}




@end
