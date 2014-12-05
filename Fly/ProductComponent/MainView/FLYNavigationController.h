//
//  FLYNavigationController.h
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYNavigationBar;

@interface FLYNavigationController : UINavigationController


- (FLYNavigationBar *)flyNavigationBar;
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated __attribute__((objc_requires_super));

@end
