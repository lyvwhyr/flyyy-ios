//
//  UniversalViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYBarButtonItem.h"
#import "UIViewController+StatusBar.h"
#import "FLYEndpointRequest.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYUniversalViewController ()

@property (nonatomic) BOOL hasSetNavigationItem;

@end

@implementation FLYUniversalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    #if DEBUG
    [[FLEXManager sharedManager] showExplorer];
    #endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.flyNavigationController.flyNavigationBar setColor:[self preferredNavigationBarColor] animated:YES];
    [self.flyNavigationController setStatusBarColor:[self preferredStatusBarColor]];
    
    [FLYEndpointRequest getGroupList];
}

- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class]]) {
        return  (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

- (UINavigationItem *)navigationItem
{
    if (!_hasSetNavigationItem) {
        _hasSetNavigationItem = YES;
        [self loadLeftBarButton];
        [self loadRightBarButton];
    }
    return [super navigationItem];
}

- (void)loadLeftBarButton
{
    if ([self.navigationController.viewControllers count] > 1) {
        FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _backButtonTapped];
        };
        self.navigationItem.leftBarButtonItem = barItem;
    }
}

- (void)loadRightBarButton
{
}


- (UIColor *)preferredNavigationBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredNavigationBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredNavigationBarColor)];
    }
    return [UIColor whiteColor];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIColor*)preferredStatusBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredStatusBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredStatusBarColor)];
    }
    return [UIColor clearColor];
}

- (void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
