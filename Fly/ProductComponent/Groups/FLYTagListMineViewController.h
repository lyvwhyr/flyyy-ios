//
//  FLYGroupListMineViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@protocol FLYTagListMineViewControllerDelegate

- (UIViewController *)rootViewController;

@end

@interface FLYTagListMineViewController : FLYUniversalViewController

@property (nonatomic) UIView *containerView;
@property (nonatomic) id<FLYTagListMineViewControllerDelegate> delegate;

@end
