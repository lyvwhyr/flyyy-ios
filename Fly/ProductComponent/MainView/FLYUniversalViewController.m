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

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYUniversalViewController ()

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


- (UIColor *)preferredNavigationBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredNavigationBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredNavigationBarColor)];
    }
    return [UIColor flyGreen];
}

@end
