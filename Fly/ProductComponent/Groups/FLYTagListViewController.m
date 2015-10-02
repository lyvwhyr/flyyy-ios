//
//  FLYGroupListViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListViewController.h"
#import "FLYTagListGlobalViewController.h"
#import "FLYTagListMineViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"
#import "FLYTagListBaseViewController.h"

@interface FLYTagListViewController () <FLYTagListMineViewControllerDelegate, FLYTagListGlobalViewControllerDelegate>

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYTagListGlobalViewController *globalVC;
@property (nonatomic) FLYTagListMineViewController *mineVC;

@end

@implementation FLYTagListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupSegmentedControl];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

- (void)_setupSegmentedControl
{
    
    self.globalVC = [FLYTagListGlobalViewController new];
    self.globalVC.controller = self;
    [self.view addSubview:self.globalVC.view];
    
    self.mineVC = [FLYTagListMineViewController new];
    self.globalVC.delegate = self;
    [self.view bringSubviewToFront:self.globalVC.view];
    
    @weakify(self);
    self.segmentedControl = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 140, 28)
                                                                     items:@[[[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListGlobalTab") andIcon:nil], [[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListMineTab") andIcon:nil]]
                                                              iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                  @strongify(self)
                                                                  if (segmentIndex == FLYSegmentedControlStateGlobal) {
                                                                      [self.mineVC.view removeFromSuperview];
                                                                      self.globalVC.delegate = self;
                                                                      [self.view addSubview:self.globalVC.view];
                                                                      [self.view bringSubviewToFront:self.globalVC.view];
                                                                  } else {
                                                                      [self.globalVC.view removeFromSuperview];
                                                                      self.mineVC.delegate = self;
                                                                      [self.view addSubview:self.mineVC.view];
                                                                      [self.view bringSubviewToFront:self.mineVC.view];
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

- (void)updateViewConstraints
{
    if ([self.mineVC.view superview]) {
        [self.mineVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    if ([self.globalVC.view superview]) {
        [self.globalVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [super updateViewConstraints];
}

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


@end
