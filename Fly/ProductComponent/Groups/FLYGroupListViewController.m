//
//  FLYGroupListViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYGroupListViewController.h"
#import "FLYGroupListGlobalViewController.h"
#import "FLYGroupListMineViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"

@interface FLYGroupListViewController ()

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYGroupListGlobalViewController *globalVC;
@property (nonatomic) FLYGroupListMineViewController *mineVC;

@end

@implementation FLYGroupListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupSegmentedControl];
}

- (void)_setupSegmentedControl
{
    self.globalVC = [FLYGroupListGlobalViewController new];
    self.globalVC.controller = self;
    self.mineVC = [FLYGroupListMineViewController new];
    [self.view addSubview:self.globalVC.view];
    [self.view addSubview:self.mineVC.view];
    [self.view bringSubviewToFront:self.globalVC.view];
    
    @weakify(self);
    self.segmentedControl = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 183, 28)
                                                                     items:@[[[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListGlobalTab") andIcon:nil], [[PPiFlatSegmentItem alloc] initWithTitle:LOC(@"FLYTagListMineTab") andIcon:nil]]
                                                              iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
                                                                  @strongify(self)
                                                                  if (segmentIndex == FLYSegmentedControlStateGlobal) {
                                                                      [self.view bringSubviewToFront:self.globalVC.view];
                                                                  } else {
                                                                      [self.view addSubview:self.mineVC.view];
                                                                  }
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

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}


@end
