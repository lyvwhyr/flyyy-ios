//
//  FLYBarButton.m
//  Fly
//
//  Created by Xingxing Xu on 12/5/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYBarButtonItem.h"
#import "UIView+FLYAddition.h"


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
    UIImage *image = [UIImage imageNamed:@"icon_back"];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    CGFloat x = (left ? -1 : 1) * 16;
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
    UIImage *image = [UIImage imageNamed:@"icon_join_group"];
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
    UIImage *image = [UIImage imageNamed:@"icon_group_checkmark"];
    CGFloat x = (left ? -1 : 1) * 16;
    backButton.frame = CGRectMake(x, 0, 52, 44);
    [backButton setImage:image forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end

