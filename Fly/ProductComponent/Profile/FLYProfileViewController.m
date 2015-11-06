//
//  FLYProfileViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYProfileViewController.h"
#import "UIColor+FLYAddition.h"

@interface FLYProfileViewController ()

@property (nonatomic) UIImageView *bgImageView;

@end

@implementation FLYProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.title = @"Me";
    self.bgImageView = [UIImageView new];
    self.bgImageView.image = [UIImage imageNamed:@"profile_bg"];
    [self.view addSubview:self.bgImageView];
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
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
