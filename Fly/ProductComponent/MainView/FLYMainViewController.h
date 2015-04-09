//
//  FLYMainViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class FLYNavigationController;
@class FLYTabBarView;
@class FLYTabView;

typedef NS_ENUM(NSInteger, TabBarItemIndex) {
    TABBAR_HOME = 0,
    TABBAR_GROUP
};

@interface FLYMainViewController : FLYUniversalViewController

@property (nonatomic) FLYTabBarView *tabBarView;
@property (nonatomic) FLYTabView *homeTab;
@property (nonatomic) FLYTabView *groupsTab;
@property (nonatomic) UIButton *recordButton;

- (FLYNavigationController *)flyNavigationController;

@end
