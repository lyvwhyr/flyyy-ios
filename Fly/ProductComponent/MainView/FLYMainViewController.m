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
#import "FLYGroupListViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "FLYFilterHomeFeedSelectorViewController.h"
#import "FLYIconButton.h"
#import "FLYNavigationBarMyGroupButton.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYMainViewController() <FLYTabBarViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) FLYTabBarView *tabBarView;

@property (nonatomic) FLYFeedViewController *feedViewController;
//@property (nonatomic) FLYRecordViewController *recordViewController;
@property (nonatomic) FLYGroupListViewController *groupsViewController;
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
//    self.title = @"FLY";
    self.view.userInteractionEnabled = YES;
    [self _addTabBar];
    [self _addNavigationBar];
    [self _addChildControllers];
}

- (void)_addNavigationBar
{
    PaperButton *button = [PaperButton button];
    button.tintColor = [UIColor whiteColor];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    
    FLYNavigationBarMyGroupButton *leftButton = [[FLYNavigationBarMyGroupButton alloc] initWithFrame:CGRectMake(0, 0, 120, 32) Title:@"My Groups" icon:@"icon_down_arrow"];
    
    [leftButton addTarget:self action:@selector(_filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    self.navigationItem.titleView = leftButton;
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
    
    _groupsViewController = [FLYGroupListViewController new];
    _groupsViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addChildViewController:_groupsViewController];
    
    _currentViewController = _feedViewController;
    [self.view addSubview:_feedViewController.view];
//    [self.view addSubview:_groupsViewController.view];
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
        if (_currentViewController == _feedViewController) {
            return;
        }
        [self showController:_feedViewController withView:_feedViewController.view animated:YES];
    } else if (index == TABBAR_RECORD) {
        FLYRecordViewController *recordViewController = [FLYRecordViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:recordViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        self.navigationItem.title = @"Groups";
        if (_currentViewController == _groupsViewController) {
            return;
        }
        [self showController:_groupsViewController withView:_groupsViewController.view animated:YES];
        
    }
}

- (void) showController:(UIViewController*)newC withView:(UIView*)contentView animated:(BOOL)animated
{
    UIViewController *oldC = self.childViewControllers.firstObject;
    if (oldC == newC) {
        return;
    }
    _currentViewController = (FLYUniversalViewController *)newC;
    
    [oldC willMoveToParentViewController:nil];
    
    [self addChildViewController:newC];
    newC.view.frame = (CGRect){ 0, 0, contentView.frame.size };
    
    if (animated && oldC != nil) {
        oldC.view.alpha = 1.0f;
        newC.view.alpha = 0.0f;
        [self transitionFromViewController:oldC toViewController:newC duration:0.0f options:0 animations:^{
            
            oldC.view.alpha = 0.0f;
            newC.view.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            [oldC removeFromParentViewController];
            [newC didMoveToParentViewController:self];
        }];
    } else {
        [contentView addSubview:newC.view];
        oldC.view.alpha = 0.0f;
        newC.view.alpha = 1.0f;
        [self transitionFromViewController:oldC toViewController:newC duration:0.25f options:0 animations:^{
            
            oldC.view.alpha = 0.0f;
            newC.view.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            [oldC removeFromParentViewController];
            [newC didMoveToParentViewController:self];
        }];
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
//    [self.navigationController pushViewController:vc animated:YES];    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:vc animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
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
