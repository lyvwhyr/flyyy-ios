//
//  FLYBarButton.m
//  Fly
//
//  Created by Xingxing Xu on 12/5/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYBarButtonItem.h"
#import "UIView+FLYAddition.h"
#import "UIButton+TouchAreaInsets.h"
#import "UIImage+FLYAddition.h"


@implementation FLYBarButtonItem

+ (instancetype)barButtonItem:(BOOL)left
{
    return [[self alloc] initWithSide:left];
}

- (instancetype)initWithSide:(BOOL)left
{
    
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithButton:(UIButton *)button actionBlock:(FLYBarButtonItemActionBlock)actionBlock;
{
    _button = button;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.width, button.height)];
    [view addSubview:button];
    if (self = [super initWithCustomView:view]) {
        _actionBlock = [actionBlock copy];
        [_button addTarget:self action:@selector(barButtonItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)barButtonItemTapped:(id)sender
{
    if (_actionBlock) {
        _actionBlock(self);
    }
}

@end


@implementation FLYBackBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    //Make it (8, 6), (31,30)
    UIImage *image = [UIImage imageNamed:@"icon_back_record"];
    CGFloat x = -5;
    backButton.frame = CGRectMake(x, 0, 52, kNavBarHeight);
    [backButton setImage:image forState:UIControlStateNormal];
    backButton.touchAreaInsets = UIEdgeInsetsMake(0, 40, 15, 60);
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

@implementation FLYBlueBackBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    //Make it (8, 6), (31,30)
    UIImage *image = [UIImage imageNamed:@"icon_back_blue"];
    CGFloat x = (left ? -1 : 1) * 15;
    backButton.frame = CGRectMake(x, 0, 50, 40);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

@implementation FLYGroupsButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_homefeed_groups_blue"];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    CGFloat x = (left ? -1 : 1) * 10;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end


@implementation FLYAddGroupBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [[UIImage imageNamed:@"icon_join_group"] imageWithColorOverlay:[UIColor whiteColor]];
    CGFloat x = (left ? -1 : 1) * 16;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

@implementation FLYJoinedGroupBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [[UIImage imageNamed:@"icon_group_checkmark"] imageWithColorOverlay:[UIColor whiteColor]];
    CGFloat x = (left ? -1 : 1) * 16;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end


@implementation FLYOptionBarButtonItem : FLYBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_detail_option"];
    CGFloat x = (left ? -1 : 1) * 10;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

@implementation FLYInviteFriendBarButtonItem : FLYBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_nav_invite_friends"];
    CGFloat x = (left ? -1 : 1) * 10;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end



@implementation FLYCatalogBarButtonItem : FLYBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_navigation_catalog"];
//    CGFloat x = (left ? -1 : 1) * 15;
    backButton.frame = CGRectMake(0, 0, 32, 32);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}
@end

@implementation FLYFlagBarButtonItem : FLYBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_flag_white"];
    CGFloat x = (left ? -1 : 1) * 10;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}
@end



@implementation FLYPostRecordingNextBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    CGFloat x = (left ? -1 : 1) * 10;
    nextButton.frame = CGRectMake(x, 0, 52, 44);
    self = [super initWithButton:nextButton actionBlock:nil];
    return self;
}

@end

@implementation FLYPostRecordingPostBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    [nextButton setTitle:@"Post" forState:UIControlStateNormal];
    CGFloat x = (left ? -1 : 1) * 10;
    nextButton.frame = CGRectMake(x, 0, 52, 44);
    self = [super initWithButton:nextButton actionBlock:nil];
    return self;
}

@end

@implementation FLYPostRecordingArrowButtonItem : FLYBarButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //12 * 21
    UIImage *image = [UIImage imageNamed:@"icon_record_next"];
    CGFloat x = (left ? -1 : 1) * 10;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

@implementation FLYJoinTagButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    joinButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14];
    [joinButton setTitle:@"Join" forState:UIControlStateNormal];
    CGFloat x = (left ? -1 : 1) * 10;
    joinButton.frame = CGRectMake(x, 0, 66, 28);
    joinButton.layer.cornerRadius = 4.0f;
    joinButton.layer.borderWidth = 1.0f;
    joinButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self = [super initWithButton:joinButton actionBlock:nil];
    return self;
}

@end

@implementation FLYLeaveTagButtonItem

- (instancetype)initWithSide:(BOOL)left
{
    UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leaveButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14];
    [leaveButton setTitle:@"Leave" forState:UIControlStateNormal];
    CGFloat x = (left ? -1 : 1) * 10;
    leaveButton.frame = CGRectMake(x, 0, 66, 28);
    leaveButton.layer.cornerRadius = 4.0f;
    leaveButton.layer.borderWidth = 1.0f;
    leaveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self = [super initWithButton:leaveButton actionBlock:nil];
    return self;
}

@end

