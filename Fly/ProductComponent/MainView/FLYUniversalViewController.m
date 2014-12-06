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


- (UIColor *)preferredNavigationBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredNavigationBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredNavigationBarColor)];
    }
    return [UIColor flyGreen];
}

- (void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
