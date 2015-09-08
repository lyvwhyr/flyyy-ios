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
    self.containerView = [UIView new];
    
    if ([FLYAppStateManager sharedInstance].currentUser) {
        self.containerView = self.baseVC.view;
        [self.baseVC.view removeFromSuperview];
    } else {
        FLYEmptyStateView *notLoggedInView = [[FLYEmptyStateView alloc] initWithTitle:@"Hi!" description:@"You can begin to follow your own groups by signing up below:"];
        self.containerView = notLoggedInView;
        
        [self.rootViewController.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
}

- (void)updateViewConstraints
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (UIViewController *)rootViewController
{
    return [self.delegate rootViewController];
}

@end
