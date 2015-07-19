//
//  FLYOnboardingStartViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 4/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYOnboardingStartViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYMainViewController.h"
#import "SDiPhoneVersion.h"

@interface FLYOnboardingStartViewController ()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UITapGestureRecognizer *tapGesturRecognizer;

@end

@implementation FLYOnboardingStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide the 1px bottom line in navigation bar
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    self.imageView = [UIImageView new];
    
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        self.imageView.image = [UIImage imageNamed:@"icon_tutorial_start_iphone4_personal"];
    } else {
         self.imageView.image = [UIImage imageNamed:@"icon_tutorial_start_personal"];
    }
    self.imageView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.imageView];
    [self _addViewConstraints];
    
    self.tapGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.imageView addGestureRecognizer:self.tapGesturRecognizer];
}

- (void)_addViewConstraints
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)handleTap:(UIPanGestureRecognizer *)gr
{
    FLYMainViewController *vc = [FLYMainViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor clearColor];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor clearColor];
}

@end
