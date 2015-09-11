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

@interface FLYSegmentedFeedViewController () <FLYFeedViewControllerDelegate>

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYFeedViewController *globalVC;
@property (nonatomic) FLYFeedViewController *mineVC;

@end

@implementation FLYSegmentedFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupSegmentedControl];
}

- (void)_setupSegmentedControl
{
    self.globalVC = [FLYFeedViewController new];
    self.globalVC.delegate = self;
    [self.view addSubview:self.globalVC.view];
    
    self.segmentedControl = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 183, 28)
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

@end
