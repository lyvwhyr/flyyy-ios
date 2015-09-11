//
//  FLYGroupListMineViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListMineViewController.h"
#import "FLYTagListBaseViewController.h"
#import "FLYEmptyStateView.h"

@interface FLYTagListMineViewController () <FLYTagListBaseViewControllerDelegate>

@property (nonatomic) FLYTagListBaseViewController *baseVC;

@end

@implementation FLYTagListMineViewController

- (instancetype)init
{
    if (self = [super init]) {
        _baseVC = [[FLYTagListBaseViewController alloc] initWithTagListType:FLYTagListTypeMine];
        _baseVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.containerView = [UIView new];
    
    if ([FLYAppStateManager sharedInstance].currentUser) {
        self.containerView = self.baseVC.view;
        [self.baseVC.view removeFromSuperview];
    } else {
        FLYEmptyStateViewActionBlock actionBlock = ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequireSignupNotification object:self];
        };
        
        FLYEmptyStateView *notLoggedInView = [[FLYEmptyStateView alloc] initWithTitle:LOC(@"FLYNotLoggedInFollowTitle") description:LOC(@"FLYNotLoggedInFollowDescription") actionBlock:actionBlock];
        self.containerView = notLoggedInView;
        self.rootViewController.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)updateViewConstraints
{
    if (![FLYAppStateManager sharedInstance].currentUser) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight - 1);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    } else {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    [super updateViewConstraints];
}

- (UIViewController *)rootViewController
{
    return [self.delegate rootViewController];
}

@end
