//
//  FLYTabBarViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTabBarViewController.h"

@interface FLYTabBarViewController ()

@end

@implementation FLYTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Getters
- (FLYTabBarView *)tabBarView
{
    if (_tabBarView == nil) {
        _tabBarView = [FLYTabBarView new];
    }
    return _tabBarView;
}

@end
