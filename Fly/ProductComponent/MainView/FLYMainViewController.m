//
//  FLYMainViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYMainViewController.h"
#import "FLYNavigationController.h"
#import "UIViewController+StatusBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYTabBarView.h"
#import "FLYTabView.h"

@interface FLYMainViewController()

@property (nonatomic) FLYTabBarView *tabBarView;

@end

@implementation FLYMainViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"FLY";
    
    [self _addTabBar];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)_addTabBar
{
    self.tabBarView = [FLYTabBarView new];
    [self.view addSubview:self.tabBarView];
    [self _addConstraints];
    
    FLYTabView *homeTab = [[FLYTabView alloc] initWithTitle:@"Home" image:@"tab_bar_home_normal" recordTab:NO];
    FLYTabView *meTab = [[FLYTabView alloc] initWithTitle:@"Me" image:@"tab_bar_home_normal" recordTab:NO];
    FLYTabView *recordTab = [[FLYTabView alloc] initWithTitle:nil image:@"icon_tabbar_voice" recordTab:YES];
    NSArray *tabs = @[homeTab, recordTab, meTab];
    [self.tabBarView setTabViews:tabs];
}

- (void)_addConstraints
{
    //tabBarView size constraints
    CGFloat tabBarWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat tabBarVerticalSpacing = CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight;
    NSDictionary *metrics = @{@"tabBarViewWidth":@(tabBarWidth), @"tabBarViewHeight":@(kTabBarViewHeight), @"tabBarViewVerticalSpacing":@(tabBarVerticalSpacing)};
    NSArray *tabBarConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_tabBarView(tabBarViewWidth)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_tabBarView)];
    NSArray *tabBarConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabBarView(tabBarViewHeight)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_tabBarView)];
    [self.tabBarView addConstraints:tabBarConstraintH];
    [self.tabBarView addConstraints:tabBarConstraintV];
    
    //tabBarView position constraints
    NSArray *tabBarConstraintPosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_tabBarView]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_tabBarView)];
    NSArray *tabBarConstraintPosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-tabBarViewVerticalSpacing-[_tabBarView]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_tabBarView)];
    [self.view addConstraints:tabBarConstraintPosH];
    [self.view addConstraints:tabBarConstraintPosV];
    
    [super updateViewConstraints];
    
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@0.0);
//        make.left.equalTo(@0.0);
//        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
//        make.height.equalTo(@(CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight));
//    }];
}


- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

@end
