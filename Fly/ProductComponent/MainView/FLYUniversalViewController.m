//
//  UniversalViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYUniversalViewController ()

@end

@implementation FLYUniversalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    #if DEBUG
//    [[FLEXManager sharedManager] showExplorer];
//    #endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
}

@end
