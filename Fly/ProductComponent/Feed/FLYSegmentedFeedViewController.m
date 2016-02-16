//
//  FLYSegmentedFeedViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 9/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSegmentedFeedViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "FLYFeedViewController.h"
#import "FLYBarButtonItem.h"
#import "FLYCatalogViewController.h"
#import "SCLAlertView.h"
#import "FLYShareManager.h"
#import "UIBarButtonItem+Badge.h"
#import "FLYNavigationController.h"
#import "FLYTopicService.h"
#import "FLYFriendDiscoveryViewController.h"

@interface FLYSegmentedFeedViewController () <FLYFeedViewControllerDelegate>

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYFeedViewController *popularVC;
@property (nonatomic) FLYFeedViewController *recentVC;

@property (nonatomic) FLYCatalogBarButtonItem *leftBarItem;

@end

@implementation FLYSegmentedFeedViewController

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_badgeCountUpdated)
                                                     name:kActivityCountUpdatedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_newPostReceived:)
                                                     name:kNewPostReceivedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupSegmentedControl];
    
    if (![self hideLeftBarItem]) {
        [self _loadLeftBarItem];
    }
}

- (void)_setupSegmentedControl
{
    self.popularVC = [FLYFeedViewController new];
    self.popularVC.topicService = [[FLYTopicService alloc] initWithFeedOrderType:FLYFeedOrderTypePopular];
    self.popularVC.delegate = self;
    self.popularVC.feedType = FLYFeedTypePopular;
    [self addChildViewController:self.popularVC];
    [self.view addSubview:self.popularVC.view];
    
    self.segmentedControl = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 140, 28)
                                                                     items:@[[[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYHomefeedSegmentedControlPopular") andIcon:nil], [[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYHomefeedSegmentedControlRecent") andIcon:nil]]
                                                              iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                  if (segmentIndex == 0) {
                                                                      [self.recentVC.view removeFromSuperview];
                                                                      self.popularVC.delegate = self;
                                                                      [self.view addSubview:self.popularVC.view];
                                                                      [self.view bringSubviewToFront:self.popularVC.view];
                                                                  } else {
                                                                      if (!self.recentVC) {
                                                                          self.recentVC = [FLYFeedViewController new];
                                                                          self.recentVC.feedType = FLYFeedTypeHome;
                                                                          [self addChildViewController:self.recentVC];
                                                                      }
                                                                      
                                                                      [self.popularVC.view removeFromSuperview];
                                                                      self.recentVC.delegate = self;
                                                                      [self.view addSubview:self.recentVC.view];
                                                                      [self.view bringSubviewToFront:self.recentVC.view];
                                                                  }
                                                              }
                                                            iconSeparation:0];
    
    UIFont *font = [UIFont flyFontWithSize:14];
    self.segmentedControl.layer.cornerRadius = 4;
    self.segmentedControl.color = [UIColor clearColor];
    self.segmentedControl.borderWidth=.5;
    self.segmentedControl.borderColor = [UIColor whiteColor];
    self.segmentedControl.selectedColor=  [UIColor whiteColor];
    self.segmentedControl.textAttributes=@{NSFontAttributeName:font,
                                           NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.segmentedControl.selectedTextAttributes=@{NSFontAttributeName:font,
                                                   NSForegroundColorAttributeName:[UIColor flyBlue]};
    self.navigationItem.titleView = self.segmentedControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![self isFullScreen]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecordIconNotification object:self];
    }
    
    if ([self isFullScreen]) {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    } else {
        self.flyNavigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - kTabBarViewHeight);
    }
}

#pragma mark - Navigation bar
- (void)loadRightBarButton
{
    FLYInviteFriendBarButtonItem *barItem = [FLYInviteFriendBarButtonItem barButtonItem:NO];
    @weakify(self)
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _inviteFriends];
    };
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)_loadLeftBarItem
{
    _leftBarItem = [FLYCatalogBarButtonItem barButtonItem:YES];
    @weakify(self);
    _leftBarItem.actionBlock = ^(FLYBarButtonItem *item) {
        @strongify(self);
        [[FLYScribe sharedInstance] logEvent:@"nav_catelog" section:@"feed" component:nil element:nil action:@"click"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideRecordIconNotification object:self];
        
        self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        [self.view layoutIfNeeded];
        FLYCatalogViewController *vc = [FLYCatalogViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    };
    self.navigationItem.leftBarButtonItem = _leftBarItem;
}


#pragma mark - Notification helper methods
- (void)_badgeCountUpdated
{
    NSString *badgeValue;
    if ([FLYAppStateManager sharedInstance].unreadActivityCount > 9) {
        badgeValue = @"9+";
    } else {
        badgeValue = [@([FLYAppStateManager sharedInstance].unreadActivityCount) stringValue];
    }
    self.leftBarItem.badgeValue = badgeValue;
}

- (void)_newPostReceived:(NSNotification *)notif
{
    if (!self.recentVC) {
        self.recentVC = [FLYFeedViewController new];
        [self addChildViewController:self.recentVC];
    }
    
    [self.popularVC.view removeFromSuperview];
    self.recentVC.delegate = self;
    [self.view addSubview:self.recentVC.view];
    [self.view bringSubviewToFront:self.recentVC.view];
    
    [self.segmentedControl setSelected:YES segmentAtIndex:1];
}

#pragma mark - rootViewController

- (UIViewController *)rootViewController
{
    return self;
}

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

- (BOOL)hideLeftBarItem
{
    return NO;
}

- (void)_inviteFriends
{
    self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [self.view layoutIfNeeded];
    FLYFriendDiscoveryViewController *vc = [FLYFriendDiscoveryViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
