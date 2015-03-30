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
#import "FLYNotificationViewController.h"
#import "FLYEverythingElseViewController.h"

#define kSegmentedControlHeight 44

@interface FLYCatalogViewController ()<UIScrollViewDelegate>

@property (nonatomic) HMSegmentedControl *segmentedControl;
@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) FLYNotificationViewController *notificationVC;
@property (nonatomic) FLYEverythingElseViewController *everythingElseVC;

@end

@implementation FLYCatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat scrollViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat scrollViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight - kSegmentedControlHeight;
    
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
    @weakify(self)
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        @strongify(self)
        [self.scrollView setContentOffset:CGPointMake(scrollViewWidth * index, 0) animated:YES];
    }];
    [self.view addSubview:self.segmentedControl];
    
    //add scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(scrollViewWidth * 2, scrollViewHeight);
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self.view addSubview:self.scrollView];
    
    
    self.notificationVC = [FLYNotificationViewController new];
    [self.scrollView addSubview:self.notificationVC.view];
    
    self.everythingElseVC = [FLYEverythingElseViewController new];
    [self.scrollView addSubview:self.everythingElseVC.view];
    
    
    [self _addViewConstraints];
}

- (void)_addViewConstraints
{
    CGFloat scrollViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat scrollViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight - kSegmentedControlHeight;
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(kSegmentedControlHeight));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.notificationVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.leading.equalTo(@(0));
        make.width.equalTo(@(scrollViewWidth));
        make.height.equalTo(@(scrollViewHeight));
    }];
    
    [self.everythingElseVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.leading.equalTo(self.notificationVC.view.mas_trailing);
        make.width.equalTo(@(scrollViewWidth));
        make.height.equalTo(@(scrollViewHeight));
    }];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
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
