//
//  FLYMainViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <POP/POP.h>
#import "PaperButton.h"
#import "FLYMainViewController.h"
#import "FLYNavigationController.h"
#import "UIViewController+StatusBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYTabBarView.h"
#import "FLYTabView.h"
#import "FLYFeedViewController.h"
#import "FLYRecordViewController.h"
#import "FLYProfileViewController.h"
#import "FLYGroupListViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "FLYFilterHomeFeedSelectorViewController.h"
#import "FLYIconButton.h"
#import "FLYFileManager.h"
#import "SCLAlertView.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYEndpointRequest.h"
#import "FLYUser.h"
#import "NSUserDefaults+RMSaveCustomObject.h"
#import "FLYCountrySelectorViewController.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@class FLYTabBarView;

@interface FLYMainViewController() <FLYTabBarViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) FLYTabBarView *tabBarView;

@property (nonatomic) FLYFeedViewController *feedViewController;
//@property (nonatomic) FLYRecordViewController *recordViewController;
@property (nonatomic) FLYGroupListViewController *groupsListViewController;
@property (nonatomic) UIViewController *currentViewController;

@property (nonatomic) FLYNavigationController *feedViewNavigationController;
@property (nonatomic) FLYNavigationController *groupsListViewNavigationController;

@property (nonatomic) BOOL didSetConstraints;

@property (nonatomic) FLYUser *currentUser;

@end

@implementation FLYMainViewController

- (instancetype)init
{
    if (self = [super init]) {
        NSString *audioDir = [FLYFileManager audioCacheDirectory];
        [[FLYFileManager sharedInstance] debugPrintFilesAndSizeForDirectory:audioDir];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideRecordButton) name:kHideRecordIconNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showRecordButton) name:kShowRecordIconNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _addTabBar];
    [self _addChildControllers];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"icon_home_record"] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(_recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.recordButton aboveSubview:self.currentViewController.view];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
 
    
//    BOOL hasCreatedUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHasCreatedUser"];
//    if (!hasCreatedUser) {
//        [self _testCreateUser];
//    } else {
//        FLYUser *user = [[NSUserDefaults standardUserDefaults] rm_customObjectForKey:@"kUserObj"];
//        [FLYAppStateManager sharedInstance].currentUser = user;
//    }
}

- (void)_testCreateUser
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UITextField *textField = [alert addTextField:@"Choose a username"];
    [alert addButton:@"Choose" actionBlock:^(void) {
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"Done";
        HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        [HUD showInView:self.view];
        [HUD dismissAfterDelay:2.0];
        NSString *username = textField.text;
        NSString *deviceId = [FLYAppStateManager sharedInstance].deviceId;
        [FLYEndpointRequest createUserWithUsername:username deviceId:deviceId successBlock:^(id response){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHasCreatedUser"];
            FLYUser *user = [[FLYUser alloc] initWithDictionary:response];
            [FLYAppStateManager sharedInstance].currentUser = user;
            [[NSUserDefaults standardUserDefaults] rm_setCustomObject:user forKey:@"kUserObj"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }];
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"icon_feed_play"] color:[UIColor flyBlue] title:@"Username" subTitle:@"Choose a username." closeButtonTitle:nil duration:0.0f];
    
}

- (void)_addNavigationBar
{
//    PaperButton *button = [PaperButton button];
//    button.tintColor = [UIColor flyBlue];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.rightBarButtonItem = barButton;
    
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
}

- (void)_addTabBar
{
    self.tabBarView = [FLYTabBarView new];
    [self.view addSubview:self.tabBarView];
    
    FLYTabView *hogroupsTab = [[FLYTabView alloc] initWithTitle:@"Home" image:@"icon_homefeed_home" recordTab:NO];
    FLYTabView *groupsTab = [[FLYTabView alloc] initWithTitle:@"Groups" image:@"icon_homefeed_group" recordTab:NO];
    
    NSArray *tabs = @[hogroupsTab, groupsTab];
    [self.tabBarView setTabViews:tabs];
    self.tabBarView.delegate = self;
}

- (void)_addChildControllers
{
    _feedViewController = [FLYFeedViewController new];
    _feedViewNavigationController= [[FLYNavigationController alloc] initWithRootViewController:_feedViewController];
    
    _groupsListViewController = [FLYGroupListViewController new];
    _groupsListViewNavigationController = [[FLYNavigationController alloc] initWithRootViewController:_groupsListViewController];
    
    _currentViewController = _feedViewNavigationController;
    [self addViewController:_currentViewController];
}

- (void)_addViewConstraints
{
    CGFloat tabBarWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [_tabBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(@(tabBarWidth));
        make.height.equalTo(@(kTabBarViewHeight));
    }];
    
    [self.recordButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tabBarView);
        make.bottom.equalTo(self.tabBarView);
    }];
}

#pragma mark - FLYTabBarViewDelegate
- (void)tabItemClicked:(NSInteger)index
{
    if (index == TABBAR_HOME) {
        if (_currentViewController == _feedViewNavigationController) {
            return;
        }
        [self removeViewController:_currentViewController];
        [self addViewController:_feedViewNavigationController];
        _currentViewController = _feedViewNavigationController;
        
        [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"bottom_bar_home_button" component:nil element:nil action:@"click"];
    } else {
        if (_currentViewController == _groupsListViewNavigationController) {
            return;
        }
        [self removeViewController:_currentViewController];
        [self addViewController:_groupsListViewNavigationController];
        _currentViewController = _groupsListViewNavigationController;
        
        [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"bottom_bar_groups_button" component:nil element:nil action:@"click"];
    }
}

- (void)removeViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
    [viewController didMoveToParentViewController:nil];
}

- (void)addViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    CGRect frame = self.view.bounds;
    frame.size.height = self.view.bounds.size.height - kTabBarViewHeight;
    viewController.view.frame = frame;
    
    //Make sure the record button is on top of current view
    [self.view insertSubview:self.recordButton aboveSubview:self.currentViewController.view];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class ]]) {
        return (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

- (void)_recordButtonTapped
{
    if (![FLYAppStateManager sharedInstance].currentUser) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRequireSignupNotification object:self userInfo:@{kFromViewControllerKey:self}];
        return;
    }

    [[FLYScribe sharedInstance] logEvent:@"home_page" section:@"bottom_bar_record_button" component:nil element:nil action:@"click"];
    
    FLYRecordViewController *recordViewController = [[FLYRecordViewController alloc] initWithRecordType:RecordingForTopic];
    UINavigationController *navigationController = [[FLYNavigationController alloc] initWithRootViewController:recordViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

#pragma mark - notification
- (void)_hideRecordButton
{
    self.recordButton.hidden = YES;
}

- (void)_showRecordButton
{
    self.recordButton.hidden = NO;
}

@end
