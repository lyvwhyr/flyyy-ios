//
//  FLYSignupPhoneNumberViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/1/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSignupPhoneNumberViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYBarButtonItem.h"

@interface FLYSignupPhoneNumberViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subTitleLabel;
@property (nonatomic) UIImageView *phoneBackgroundImage;
@property (nonatomic) UILabel *hintLabel;
@property (nonatomic) UIView *seperator;
@property (nonatomic) UILabel *alreadyHaveAccountLabel;

@end

@implementation FLYSignupPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Navigation title
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LOC(@"FLYSignupPageTitle");
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Navigation bar
- (void)loadLeftBarButton
{
    @weakify(self)
    FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _backButtonTapped];
    };
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
