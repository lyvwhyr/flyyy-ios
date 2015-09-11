//
//  FLYNavigationManager.m
//  Flyy
//
//  Created by Xingxing Xu on 6/21/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYNavigationManager.h"
#import "FLYSegmentedFeedViewController.h"
#import "NSTimer+BlocksKit.h"

@implementation FLYNavigationManager

+ (instancetype)sharedInstance
{
    static FLYNavigationManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [FLYNavigationManager new];
    });
    return manager;
}

- (FLYMainViewController *)rootViewController
{
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window.rootViewController isKindOfClass:[FLYNavigationController class]]) {
            FLYNavigationController *navController = (FLYNavigationController *)window.rootViewController;
            if ([[navController.viewControllers firstObject] isKindOfClass:[FLYMainViewController class]]) {
                return (FLYMainViewController *)[navController.viewControllers firstObject];
            }
        }
    }
    return nil;
}

- (FLYNavigationController *)rootNavController
{
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window.rootViewController isKindOfClass:[FLYNavigationController class]]) {
            return (FLYNavigationController *)window.rootViewController;
        }
    }
    return nil;
}

- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated tabIndex:(NSUInteger)tabIndex isRoot:(BOOL)isRoot
{
    [self navigateToTabBarIndex:tabIndex isRoot:isRoot animated:YES];
    
    UIViewController *visibleVewController = [self rootNavController].visibleViewController;
    if (visibleVewController.presentingViewController != nil) {
        [visibleVewController dismissViewControllerAnimated:NO completion:^{
            [self navigateToViewController:viewController animated:NO tabIndex:tabIndex isRoot:isRoot];
        }];
        return;
    }
    
    if (viewController) {
        UINavigationController *navViewController = [self rootViewController].feedViewNavigationController;
        [navViewController popToRootViewControllerAnimated:NO];
        
        void (^pushViewController)() = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kHideRecordIconNotification object:self];
                navViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
                [[self rootViewController].feedViewController.view layoutIfNeeded];
                [navViewController pushViewController:viewController animated:YES];
            });
        };
        [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:pushViewController repeats:NO];
        
    }
}

- (void)navigateToTabBarIndex:(NSUInteger)tabBarIndex isRoot:(BOOL)isRoot animated:(BOOL)animated
{
    FLYNavigationController *rootNavController = [self rootNavController];
    [rootNavController popToRootViewControllerAnimated:animated];
    [[self rootViewController] setTabIndex:TABBAR_HOME];
}


@end
