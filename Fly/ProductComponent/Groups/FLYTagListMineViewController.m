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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_successfulLogin:) name:kSuccessfulLoginNotification object:nil];
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
        
        FLYEmptyStateView *notLoggedInView = [[FLYEmptyStateView alloc] initWithTitle:LOC(@"FLYNotLoggedInFollowTitle") description:LOC(@"FLYNotLoggedInFollowDescription") buttonText:nil actionBlock:actionBlock];
        self.containerView = notLoggedInView;
        self.rootViewController.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    }
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
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

- (void)_successfulLogin:(NSNotification *)notification
{
    [self.containerView removeFromSuperview];
    
    self.containerView = self.baseVC.view;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

- (UIViewController *)rootViewController
{
    return [self.delegate rootViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
