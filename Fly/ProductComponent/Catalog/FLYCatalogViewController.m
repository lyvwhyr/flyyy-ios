//
//  FLYCatalogViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYCatalogViewController.h"
#import "HMSegmentedControl.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

@interface FLYCatalogViewController ()

@property (nonatomic) HMSegmentedControl *segmentedControl;

@end

@implementation FLYCatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Notifications", @"Everything else"]];
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorHeight = 2.0f;
    UIFont *font = [UIFont flyFontWithSize:15];
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor flyBlue], NSFontAttributeName : font}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    [self _addViewConstraints];
}

- (void)_addViewConstraints
{
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
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
