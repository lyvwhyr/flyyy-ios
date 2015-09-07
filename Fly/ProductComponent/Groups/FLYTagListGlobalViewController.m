//
//  FLYGroupsViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTagListGlobalViewController.h"
#import "FLYTagListTableViewCell.h"
#import "FLYTagListSuggestTableViewCell.h"
#import "SCLAlertView.h"
#import "UIColor+FLYAddition.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYMainViewController.h"
#import "FLYFeedViewController.h"
#import "FLYGroupViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYTagListCell.h"
#import "FLYGroupManager.h"
#import "FLYGroup.h"
#import "Dialog.h"
#import "PPiFlatSegmentedControl.h"
#import "UIFont+FLYAddition.h"
#import "FLYSearchBar.h"
#import "FLYTagListViewController.h"
#import "FLYHintView.h"
#import "FLYTagListBaseViewController.h"


#define kSuggestGroupRow 0

@interface FLYTagListGlobalViewController ()

@property (nonatomic) FLYTagListBaseViewController *baseVC;

@end

@implementation FLYTagListGlobalViewController

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
