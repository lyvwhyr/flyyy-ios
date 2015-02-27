//
//  UniversalViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYNavigationController;

typedef NS_ENUM(NSInteger, FLYViewControllerState) {
    FLYViewControllerStateReady = 0,
    FLYViewControllerStateLoading,
    FLYViewControllerStateError
};

@interface FLYUniversalViewController : UIViewController

@property (nonatomic) UIButton *leftNavBarButton;
@property (nonatomic) UIButton *rightBarButton;
@property (nonatomic) UIView *titleNavBarView;
@property (nonatomic) FLYViewControllerState state;

- (FLYNavigationController *)flyNavigationController;
- (UIColor *)preferredNavigationBarColor;
- (UIColor*)preferredStatusBarColor;

- (void)loadLeftBarButton;
- (void)loadRightBarButton;

@end
