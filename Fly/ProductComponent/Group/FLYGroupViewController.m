//
//  FLYGroupViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/30/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupViewController.h"
#import "FLYFeedViewController.h"
#import "FLYBarButtonItem.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"

@interface FLYGroupViewController ()

//@property (nonatomic) FLYFeedViewController *feedViewController;

@property (nonatomic) UILabel *groupTitleLabel;

@property (nonatomic) BOOL hasJoinedGroup;

@end

@implementation FLYGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _feedViewController = [FLYFeedViewController new];
//    [self.view addSubview:_feedViewController.view];
//    _feedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    [self.view layoutIfNeeded];
//    [FLYUtilities printAutolayoutTrace];
}

- (void)updateViewConstraints
{
    
//    [self.view removeConstraints:self.view.constraints];
//    [_feedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view);
//        make.leading.equalTo(self.view);
//        make.width.equalTo(self.view);
//        make.height.equalTo(self.view);
//    }];
    [super updateViewConstraints];
}

- (UINavigationItem *)navigationItem
{
    if (!_groupTitleLabel) {
        _groupTitleLabel = [UILabel new];
        _groupTitleLabel.text = @"I'm so anxious about finals I can't sleep";
        _groupTitleLabel.textColor = [UIColor whiteColor];
        _groupTitleLabel.font = [UIFont systemFontOfSize:15];
        [_groupTitleLabel sizeToFit];
        
        [self.navigationItem setTitleView:_groupTitleLabel];
    }
    return [super navigationItem];
}

- (void)loadRightBarButton
{
    if (!_hasJoinedGroup) {
        FLYAddGroupBarButtonItem *barItem = [FLYAddGroupBarButtonItem barButtonItem:NO];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.hasJoinedGroup = YES;
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.textLabel.text = @"Joined";
            HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [HUD showInView:self.view];
            [HUD dismissAfterDelay:2.0];

            [self loadRightBarButton];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
        FLYJoinedGroupBarButtonItem *barItem = [FLYJoinedGroupBarButtonItem barButtonItem:NO];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.hasJoinedGroup = NO;
            [self loadRightBarButton];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    }
}

@end
