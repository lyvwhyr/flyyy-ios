//
//  UIViewController+StatusBar.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "UIViewController+StatusBar.h"

@implementation UIViewController (StatusBar)

- (void)setStatusBarColor:(UIColor *)color
{
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kStatusBarHeight)];
    statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusBar.backgroundColor = color;
    [self.view addSubview:statusBar];
    [self.view bringSubviewToFront:statusBar];
}

@end
