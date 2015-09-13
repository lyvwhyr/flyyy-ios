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

@interface FLYSegmentedFeedViewController () <FLYFeedViewControllerDelegate>

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYFeedViewController *globalVC;
@property (nonatomic) FLYFeedViewController *mineVC;

@property (nonatomic) FLYCatalogBarButtonItem *leftBarItem;

@end

@implementation FLYSegmentedFeedViewController

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_badgeCountUpdated)
                                                     name:kActivityCountUpdatedNotification object:nil];
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
    self.globalVC = [FLYFeedViewController new];
    self.globalVC.delegate = self;
    [self.view addSubview:self.globalVC.view];
    
    self.segmentedControl = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 140, 28)
                                                                     items:@[[[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListGlobalTab") andIcon:nil], [[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListMineTab") andIcon:nil]]
                                                              iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
                                                              }
                                                            iconSeparation:0];
    self.segmentedControl.layer.cornerRadius = 4;
    self.segmentedControl.color = [UIColor clearColor];
    self.segmentedControl.borderWidth=.5;
    self.segmentedControl.borderColor = [UIColor whiteColor];
    self.segmentedControl.selectedColor=  [UIColor whiteColor];
    self.segmentedControl.textAttributes=@{NSFontAttributeName:[UIFont flyFontWithSize:16],
                                           NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.segmentedControl.selectedTextAttributes=@{NSFontAttributeName:[UIFont flyFontWithSize:16],
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Navigation bar
- (void)loadRightBarButton
{
    FLYInviteFriendBarButtonItem *barItem = [FLYInviteFriendBarButtonItem barButtonItem:NO];
    @weakify(self)
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _shareTapped];
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

- (void)_shareTapped
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:LOC(@"FLYInviteFriendsInviteButtonText") actionBlock:^(void) {
        [FLYShareManager inviteFriends:self];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] color:[UIColor flyBlue] title:LOC(@"FLYInviteFriendsTitleText") subTitle:LOC(@"FLYInviteFriendsSubTitleText") closeButtonTitle:LOC(@"FLYButtonCancelText") duration:0.0f];
}


@end
