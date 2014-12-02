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
@property (nonatomic) FLYGroupListViewController *groupsListViewController;
@property (nonatomic) FLYUniversalViewController *currentViewController;

@property (nonatomic) BOOL didSetConstraints;

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
}



- (void)_addTabBar
{
    self.tabBarView = [FLYTabBarView new];
    [self.view addSubview:self.tabBarView];
    
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
//    [self addChildViewController:_feedViewController];
    
    _groupsListViewController = [FLYGroupListViewController new];
    _groupsListViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    _currentViewController = _feedViewController;
//    [self.view addSubview:_feedViewController.view];
    
    [self addViewController:_feedViewController];
}

- (void)_addViewConstraints
{
    CGFloat tabBarWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat tabBarVerticalSpacing = CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarHeight - kNavBarHeight - kTabBarViewHeight;
    
    [_tabBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.width.equalTo(@(tabBarWidth));
        make.height.equalTo(@(kTabBarViewHeight));
        make.top.equalTo(self.view).offset(tabBarVerticalSpacing);
    }];
    
    if (_feedViewController.view.superview) {
        [_feedViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.width.equalTo(@(CGRectGetWidth(self.view.bounds)));
            make.height.equalTo(@(CGRectGetHeight(self.view.bounds) - kTabBarViewHeight));
        }];
    }
    
    if (_groupsListViewController.view.superview) {
        [_groupsListViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.width.equalTo(@(CGRectGetWidth(self.view.bounds)));
            make.height.equalTo(@(CGRectGetHeight(self.view.bounds) - kTabBarViewHeight));
        }];
    }
}

#pragma mark - FLYTabBarViewDelegate
- (void)tabItemClicked:(NSInteger)index
{
    [self removeViewController:_currentViewController];
    if (index == TABBAR_HOME) {
        if (_currentViewController == _feedViewController) {
            return;
        }
        [self addViewController:_feedViewController];
        _currentViewController = _feedViewController;
    } else if (index == TABBAR_RECORD) {
        FLYRecordViewController *recordViewController = [FLYRecordViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:recordViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        if (_currentViewController == _groupsListViewController) {
            return;
        }
//        [self showController:_groupsListViewController withView:_groupsListViewController.view animated:YES];
        [self addViewController:_groupsListViewController];
        _currentViewController = _groupsListViewController;
    }
}

- (void)removeViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [viewController didMoveToParentViewController:nil];
}

- (void)addViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
//    viewController
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self _addViewConstraints];
}

- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

@end
