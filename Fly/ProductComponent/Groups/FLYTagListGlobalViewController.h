//
//  FLYGroupsViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class FLYTagListViewController;

@protocol FLYTagListGlobalViewControllerDelegate

- (UIViewController *)rootViewController;

@end

@interface FLYTagListGlobalViewController : FLYUniversalViewController

@property (nonatomic) FLYTagListViewController *controller;
@property (nonatomic) UIView *containerView;
@property (nonatomic, weak) id<FLYTagListGlobalViewControllerDelegate> delegate;

@end
