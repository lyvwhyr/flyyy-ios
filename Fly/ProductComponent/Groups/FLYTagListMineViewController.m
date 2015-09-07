//
//  FLYGroupListMineViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListMineViewController.h"
#import "FLYTagListBaseViewController.h"

@interface FLYTagListMineViewController () <FLYTagListBaseViewControllerDelegate>

@property (nonatomic) FLYTagListBaseViewController *baseVC;

@end

@implementation FLYTagListMineViewController

- (instancetype)init
{
    if (self = [super init]) {
        _baseVC = [[FLYTagListBaseViewController alloc] init];
        _baseVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.containerView = [UIView new];
    self.containerView = self.baseVC.view;
    [self.baseVC.view removeFromSuperview];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
}

- (void)updateViewConstraints
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (UIViewController *)rootViewController
{
    return [self.delegate rootViewController];
}

@end
