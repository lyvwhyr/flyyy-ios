//
//  FLYGroupListMineViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListMineViewController.h"
#import "FLYTagListBaseViewController.h"

@interface FLYTagListMineViewController ()

@property (nonatomic) FLYTagListBaseViewController *baseVC;

@end

@implementation FLYTagListMineViewController

- (instancetype)init
{
    if (self = [super init]) {
        _baseVC = [[FLYTagListBaseViewController alloc] init];
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

@end
