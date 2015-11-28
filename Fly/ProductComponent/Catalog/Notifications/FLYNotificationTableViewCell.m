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
#define kLeftMargin 40
#define kRightMargin 30

@interface FLYNotificationTableViewCell()

@property (nonatomic) UIImageView *dotView;
@property (nonatomic) TTTAttributedLabel *activityLabel;
@property (nonatomic) UILabel *createdAt;

@property (nonatomic) FLYNotification *notification;

@end

@implementation FLYNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _dotView = [UIImageView new];
        _dotView.image = [UIImage imageNamed:@"icon_dot"];
        _dotView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_dotView];
        
        _activityLabel = [TTTAttributedLabel new];
        _activityLabel.textColor = [UIColor flyBlue];
        _activityLabel.numberOfLines = 0;
        _activityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_activityLabel];
        
        _createdAt = [UILabel new];
        _createdAt.font = [UIFont fontWithName:@"Avenir-Book" size:9];
        _createdAt.textColor = [UIColor flyColorFlyReplyPostAtGrey];
        [self.contentView addSubview:_createdAt];
    }
    return self;
}

- (void)setupCell:(FLYNotification *)notification
{
    self.notification = notification;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:notification.notificationString];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    
    NSInteger len = [notification.notificationString.string length];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, len)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor flyBlue] range:NSMakeRange(0, len)];
    self.activityLabel.attributedText = attrStr;
    
    if (!notification.isRead) {
        self.dotView.hidden = NO;
        self.backgroundColor = [FLYUtilities colorWithHexString:@"#F3F3F3"];
    } else {
        self.dotView.hidden = YES;
        self.backgroundColor = [UIColor flySettingBackgroundColor];
    }
    
    [self.createdAt setText:self.notification.displayableCreateAt];
    
    [self.activityLabel sizeToFit];
}

- (void)clearReadState
{
    self.notification.isRead = YES;
    self.dotView.hidden = YES;
    self.backgroundColor = [UIColor flySettingBackgroundColor];
    [self setNeedsDisplay];
}

+ (CGFloat)heightForNotification:(FLYNotification *)notification
{
    if ([notification.action isEqualToString:@"followed"]) {
        return 44;
    }
    
    if (notification.notificationString == nil) {
        return 0;
    }
    
    CGFloat height = 0;
    TTTAttributedLabel *dummyLabel = [TTTAttributedLabel new];
    dummyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:notification.notificationString];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 2;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, notification.notificationString.length)];
    dummyLabel.attributedText = attrStr;
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - kLeftMargin - kRightMargin;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    //top, bottom, padding
    height += rect.size.height + kTopMargin + kBottomMargin;
    return height;
}

- (void)updateConstraints
{
    if (!self.dotView.hidden) {
        [self.dotView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(17);
            make.centerY.equalTo(self);
        }];
    }
    
    [self.activityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kLeftMargin);
        make.top.equalTo(self).offset(kTopMargin);
        make.trailing.lessThanOrEqualTo(self).offset(-kRightMargin);
    }];
    
    [self.createdAt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-5);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
    
    [super updateConstraints];
}

@end
