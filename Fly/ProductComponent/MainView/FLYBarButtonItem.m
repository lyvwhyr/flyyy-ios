//
//  FLYBarButton.m
//  Fly
//
//  Created by Xingxing Xu on 12/5/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYBarButtonItem.h"


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
    if (self = [super initWithCustomView:button]) {
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
    [backButton setFrame:CGRectMake(0, 0, 52, 44)];
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    self = [super initWithButton:backButton actionBlock:nil];
    return self;
}

@end
