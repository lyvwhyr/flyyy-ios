//
//  FLYNavigationManager.h
//  Flyy
//
//  Created by Xingxing Xu on 6/21/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYNavigationController.h"
#import "FLYMainViewController.h"

@interface FLYNavigationManager : NSObject


+ (instancetype)sharedInstance;

- (FLYMainViewController *)rootViewController;
- (FLYNavigationController *)rootNavController;
- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated tabIndex:(NSUInteger)tabIndex isRoot:(BOOL)isRoot;
- (void)navigateToTabBarIndex:(NSUInteger)tabBarIndex isRoot:(BOOL)isRoot animated:(BOOL)animated;

@end
