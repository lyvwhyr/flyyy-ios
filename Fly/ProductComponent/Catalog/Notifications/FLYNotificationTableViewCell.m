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
#import "FLYNotification.h"

#define kTopMargin   10
#define kBottomMargin 10
#define kLeftMargin 20
#define kRightMargin 20

@interface FLYNotificationTableViewCell()

@property (nonatomic) TTTAttributedLabel *activityLabel;

@end

@implementation FLYNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _activityLabel = [TTTAttributedLabel new];
        _activityLabel.textColor = [UIColor flyBlue];
        _activityLabel.numberOfLines = 0;
        _activityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_activityLabel];
    }
    return self;
}

- (void)setupCell:(FLYNotification *)notification
{
    self.activityLabel.text = notification.notificationString;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.activityLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    
    NSInteger len = [self.activityLabel.text length];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, len)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, len)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor flyTopicTitleColor] range:NSMakeRange(0, len)];
    
    self.activityLabel.attributedText = attrStr;
    [self.activityLabel sizeToFit];
}

+ (CGFloat)heightForNotification:(FLYNotification *)notification
{
    if (notification.notificationString == 0) {
        return 0;
    }
    
    CGFloat height = 0;
    UILabel *dummyLabel = [UILabel new];
    dummyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    dummyLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:notification.notificationString];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, notification.notificationString.length)];
    [attrStr addAttribute:NSFontAttributeName value:dummyLabel.font range:NSMakeRange(0, notification.notificationString.length)];
    dummyLabel.attributedText = attrStr;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - kLeftMargin - kRightMargin;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //top, bottom, padding
    height += rect.size.height + kTopMargin + kBottomMargin;
    return height;
}

- (void)updateConstraints
{
    [self.activityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kLeftMargin);
        make.top.equalTo(self).offset(kTopMargin);
        make.trailing.lessThanOrEqualTo(self).offset(-kRightMargin);
    }];
    
    [super updateConstraints];
}

@end
