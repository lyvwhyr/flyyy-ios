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
@class FLYTagListViewController;
@class FLYSegmentedFeedViewController;
@class FLYProfileViewController;

typedef NS_ENUM(NSInteger, TabBarItemIndex) {
    TABBAR_HOME = 0,
    TABBAR_GROUP,
    TABBAR_RECORD,
    TABBAR_ME
};

@interface FLYMainViewController : FLYUniversalViewController

@property (nonatomic) FLYTabBarView *tabBarView;
@property (nonatomic) FLYTabView *homeTab;
@property (nonatomic) FLYTabView *groupsTab;
@property (nonatomic) FLYTabView *recordTab;
@property (nonatomic) FLYTabView *meTab;

@property (nonatomic) UIButton *recordButton;

@property (nonatomic) FLYSegmentedFeedViewController *feedViewController;
@property (nonatomic) FLYTagListViewController *groupsListViewController;
@property (nonatomic) FLYProfileViewController *profileViewController;
@property (nonatomic) UIViewController *currentViewController;

@property (nonatomic) FLYNavigationController *feedViewNavigationController;
@property (nonatomic) FLYNavigationController *profileViewNavigationController;

- (FLYNavigationController *)flyNavigationController;
- (void)setTabIndex:(NSUInteger)index;

@end
