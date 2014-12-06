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
@property (nonatomic) UIViewController *currentViewController;

@property (nonatomic) FLYNavigationController *feedViewNavigationController;
@property (nonatomic) FLYNavigationController *groupsListViewNavigationController;

@property (nonatomic) BOOL didSetConstraints;

@end

@implementation FLYMainViewController

- (instancetype)init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self _addTabBar];
//    [self _addNavigationBar];
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
    _feedViewNavigationController= [[FLYNavigationController alloc] initWithRootViewController:_feedViewController];
    
    _groupsListViewController = [FLYGroupListViewController new];
    _groupsListViewNavigationController = [[FLYNavigationController alloc] initWithRootViewController:_groupsListViewController];
    
    _currentViewController = _feedViewNavigationController;
    [self addViewController:_currentViewController];
}

- (void)_addViewConstraints
{
    CGFloat tabBarWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [_tabBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(@(tabBarWidth));
        make.height.equalTo(@(kTabBarViewHeight));
    }];
}

#pragma mark - FLYTabBarViewDelegate
- (void)tabItemClicked:(NSInteger)index
{
    if (index == TABBAR_HOME) {
        if (_currentViewController == _feedViewNavigationController) {
            return;
        }
        [self removeViewController:_currentViewController];
        [self addViewController:_feedViewNavigationController];
        _currentViewController = _feedViewNavigationController;
    } else if (index == TABBAR_RECORD) {
        FLYRecordViewController *recordViewController = [FLYRecordViewController new];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:recordViewController];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        if (_currentViewController == _groupsListViewNavigationController) {
            return;
        }
        [self removeViewController:_currentViewController];
        [self addViewController:_groupsListViewNavigationController];
        _currentViewController = _groupsListViewNavigationController;
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
    
    CGRect frame = self.view.bounds;
    frame.size.height = self.view.bounds.size.height - kTabBarViewHeight;
    viewController.view.frame = frame;
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
    [FLYUtilities printAutolayoutTrace];
}

- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

@end
