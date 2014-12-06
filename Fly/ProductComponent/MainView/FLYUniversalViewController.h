//
//  UniversalViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYNavigationController;

@interface FLYUniversalViewController : UIViewController

@property (nonatomic) UIButton *leftNavBarButton;
@property (nonatomic) UIButton *rightBarButton;
@property (nonatomic) UIView *titleNavBarView;

- (FLYNavigationController *)flyNavigationController;
- (UIColor *)preferredNavigationBarColor;
- (UIColor*)preferredStatusBarColor;

- (void)loadLeftBarButton;
- (void)loadRightBarButton;

@end
