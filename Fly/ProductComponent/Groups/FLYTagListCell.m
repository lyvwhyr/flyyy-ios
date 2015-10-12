//
//  FLYPrePostChooseGroupTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTagListCell.h"
#import "UIColor+FLYAddition.h"
#import "FLYTagsManager.h"
#import "FLYTagsService.h"
#import "UIButton+TouchAreaInsets.h"

@interface FLYTagListCell()

@property (nonatomic) BOOL hasJoinedGroup;

@end

@implementation FLYTagListCell

#define kLeftPadding 20
#define kRightPadding 20
#define kSeparatorRightPadding 10

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _groupNameLabel = [UILabel new];
        _groupNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _groupNameLabel.textColor = [UIColor flyColorFlyGroupNameGrey];
        [_groupNameLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        [self addSubview:_groupNameLabel];
        
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_checkButton setImage:[UIImage imageNamed:@"icon_join_group_grey_border"] forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(_actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _checkButton.touchAreaInsets = UIEdgeInsetsMake(3, 5, 3, 5);
        [_checkButton sizeToFit];
        [self addSubview:_checkButton];
        
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor flyGrey];
        _separator.alpha = 0.5f;
        _separator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_separator];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setGroup:(FLYGroup *)group
{
    _group = group;
    self.hasJoinedGroup = [[FLYTagsManager sharedInstance] alreadyFollowedTag:group];
    if (self.hasJoinedGroup) {
        [_checkButton setImage:[UIImage imageNamed:@"icon_leave_group"] forState:UIControlStateNormal];
    } else {
        [_checkButton setImage:[UIImage imageNamed:@"icon_join_group_grey_border"] forState:UIControlStateNormal];
    }
    
    self.groupNameLabel.text = [NSString stringWithFormat:@"#%@", group.groupName];
}

- (void)updateConstraints
{
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(kLeftPadding);
    }];
    
    [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-kRightPadding);
    }];
    
    CGFloat height = 1.0/[FLYUtilities FLYMainScreenScale];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.leading.equalTo(self).offset(kLeftPadding);
        make.trailing.equalTo(self.checkButton.mas_trailing);
        make.height.equalTo(@(height));
    }];
    
    [super updateConstraints];
}

- (void)_actionButtonTapped
{
    if (![FLYAppStateManager sharedInstance].currentUser) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRequireSignupNotification object:self];
        return;
    }
    
    if (self.hasJoinedGroup) {
        [self.checkButton setImage:[UIImage imageNamed:@"icon_join_group_grey_border"] forState:UIControlStateNormal];
        FLYFollowTagSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj)
        {
            [[FLYTagsManager sharedInstance] unFollowTag:self.group];
            self.hasJoinedGroup = NO;
        };
        
        [FLYTagsService followTagWithId:self.group.groupId followed:YES successBlock:successBlock errorBlock:nil];
    } else {
        [self.checkButton setImage:[UIImage imageNamed:@"icon_leave_group"] forState:UIControlStateNormal];
        FLYFollowTagSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj)
        {
            self.hasJoinedGroup = YES;
            [[FLYTagsManager sharedInstance] updateCurrentUserTags:[NSMutableArray arrayWithObject:self.group]];
        };
        
        [FLYTagsService followTagWithId:self.group.groupId followed:NO successBlock:successBlock errorBlock:nil];
    }
}

@end
