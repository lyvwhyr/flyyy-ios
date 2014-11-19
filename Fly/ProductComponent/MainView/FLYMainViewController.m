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
#import "FLYFeedViewController.h"
#import "FLYRecordViewController.h"
#import "FLYProfileViewController.h"

@interface FLYMainViewController() <FLYTabBarViewDelegate>

@property (nonatomic) FLYTabBarView *tabBarView;

@property (nonatomic) FLYFeedViewController *feedViewController;
@property (nonatomic) FLYRecordViewController *recordViewController;
@property (nonatomic) FLYProfileViewController *profileViewController;
@property (nonatomic) FLYUniversalViewController *currentViewController;

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
    [self _addChildControllers];
}



- (void)_addTabBar
{
    self.tabBarView = [FLYTabBarView new];
    [self.view addSubview:self.tabBarView];
    [self _addConstraints];
    
    FLYTabView *homeTab = [[FLYTabView alloc] initWithTitle:@"Home" image:@"icon_tabbar_home" recordTab:NO];
    FLYTabView *meTab = [[FLYTabView alloc] initWithTitle:@"Me" image:@"icon_tabbar_me" recordTab:NO];
    FLYTabView *recordTab = [[FLYTabView alloc] initWithTitle:nil image:@"icon_tabbar_voice" recordTab:YES];
    NSArray *tabs = @[homeTab, recordTab, meTab];
    [self.tabBarView setTabViews:tabs];
    self.tabBarView.delegate = self;
}

- (void)_addChildControllers
{
    _feedViewController = [FLYFeedViewController new];
    [self addChildViewController:_feedViewController];
    
    _recordViewController = [FLYRecordViewController new];
    [self addChildViewController:_recordViewController];
    
    _profileViewController = [FLYProfileViewController new];
    [self addChildViewController:_profileViewController];
    
    _currentViewController = _feedViewController;
    [self.view addSubview:_currentViewController.view];
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
}

#pragma mark - FLYTabBarViewDelegate
- (void)tabItemClicked:(NSInteger)index
{
    if (index == TABBAR_HOME) {
        
    } else if (index == TABBAR_RECORD) {
        [self transitionFromViewController:_currentViewController toViewController:_recordViewController duration:0 options:0 animations:nil completion:^(BOOL finished) {
            _currentViewController = _recordViewController;
        }];
    } else {
        
    }
}


- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

@end
