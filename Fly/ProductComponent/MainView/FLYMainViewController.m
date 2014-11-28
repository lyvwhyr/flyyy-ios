//
//  FLYMainViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <POP/POP.h>
#import "PaperButton.h"
#import "FLYMainViewController.h"
#import "FLYNavigationController.h"
#import "UIViewController+StatusBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYTabBarView.h"
#import "FLYTabView.h"
#import "FLYFeedViewController.h"
#import "FLYRecordViewController.h"
#import "FLYProfileViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "FLYFilterHomeFeedSelectorViewController.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYMainViewController() <FLYTabBarViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) FLYTabBarView *tabBarView;

@property (nonatomic) FLYFeedViewController *feedViewController;
//@property (nonatomic) FLYRecordViewController *recordViewController;
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
    self.view.userInteractionEnabled = YES;
    [self _addNavigationBar];
    [self _addTabBar];
    [self _addChildControllers];
}

- (void)_addNavigationBar
{
    PaperButton *button = [PaperButton button];
    button.tintColor = [UIColor whiteColor];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"icon_nav_filter"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(_filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}



- (void)_addTabBar
{
    self.tabBarView = [FLYTabBarView new];
    [self.view addSubview:self.tabBarView];
    [self _addConstraints];
    
    FLYTabView *hogroupsTab = [[FLYTabView alloc] initWithTitle:@"Home" image:@"icon_tabbar_home" recordTab:NO];
    FLYTabView *groupsTab = [[FLYTabView alloc] initWithTitle:@"Groups" image:@"icon_tabbar_group" recordTab:NO];
    FLYTabView *recordTab = [[FLYTabView alloc] initWithTitle:nil image:@"icon_tabbar_voice" recordTab:YES];
    NSArray *tabs = @[hogroupsTab, recordTab, groupsTab];
    [self.tabBarView setTabViews:tabs];
    self.tabBarView.delegate = self;
}

- (void)_addChildControllers
{
    _feedViewController = [FLYFeedViewController new];
    _feedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:_feedViewController];
    
//    [self addChildViewController:_recordViewController];
    
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
        FLYRecordViewController *recordViewController = [FLYRecordViewController new];
//        [self transitionFromViewController:_currentViewController toViewController:_recordViewController duration:0 options:0 animations:nil completion:^(BOOL finished) {
            _currentViewController = recordViewController;
//        }];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:recordViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

#pragma mark - private methods for navigation bar actions

- (void)_filterButtonTapped
{
    FLYFilterHomeFeedSelectorViewController *vc = [FLYFilterHomeFeedSelectorViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}


- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

@end
