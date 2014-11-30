//
//  FLYGroupsViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupsViewController.h"

@interface FLYGroupsViewController ()

@end

@implementation FLYGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:[self.view constraints]];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.parentViewController.view);
        make.leading.equalTo(self.parentViewController.view);
        make.width.equalTo(@(CGRectGetWidth(self.parentViewController.view.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.parentViewController.view.bounds) - kTabBarViewHeight));
    }];
    [super updateViewConstraints];
}

@end
