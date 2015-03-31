//
//  FLYLoginSignupViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/4/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginSignupViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYSignupPhoneNumberViewController.h"
#import "FLYLoginViewController.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"
#import "FLYBarButtonItem.h"
#import "FLYIconButton.h"
#import "UIFont+FLYAddition.h"

#define kTitleTopPadding   18

@interface FLYLoginSignupViewController ()

@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) FLYIconButton *logoButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UIButton *signupButton;

@end

@implementation FLYLoginSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide the 1px bottom line in navigation bar
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.view.backgroundColor = [UIColor flyBlue];
    
    UIFont *font = [UIFont flyFontWithSize:24];
    self.logoButton = [[FLYIconButton alloc] initWithText:@"Flyy" textFont:font textColor:[UIColor whiteColor]  icon:@"icon_login_wings" isIconLeft:YES];
    [self.view addSubview:self.logoButton];
    
    _titleLabel = [UILabel new];
    _titleLabel.text = LOC(@"FLYLoginTitle");
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont flyFontWithSize:20];
    [self.view addSubview:_titleLabel];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:LOC(@"FLYLoginButtonText") forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor flyBlue] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(_loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.signupButton addTarget:self action:@selector(_signupButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.signupButton.backgroundColor = [UIColor colorWithHexString:@"#88D5A8"];
    [self.signupButton setTitle:LOC(@"FLYSignupButtonText") forState:UIControlStateNormal];
    [self.view addSubview:self.signupButton];
    
    [self _addViewConstraints];
}

#pragma mark - Navigation bar

- (void)loadLeftBarButton
{
    if (self.canGoBack) {
        FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
        @weakify(self)
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            @strongify(self)
            [self _backButtonTapped];
        };
        self.navigationItem.leftBarButtonItem = barItem;
    }
}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_addViewConstraints
{
    [self.logoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-90);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.logoButton.mas_bottom).offset(kTitleTopPadding);
    }];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [self.signupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@(45));
        make.width.equalTo(self.view);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.signupButton.mas_top);
        make.height.equalTo(@(45));
        make.width.equalTo(self.view);
    }];
}

- (void)_loginButtonTapped
{
    FLYLoginViewController *vc = [FLYLoginViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_signupButtonTapped
{
    FLYSignupPhoneNumberViewController *vc = [FLYSignupPhoneNumberViewController new];
    [self.navigationController pushViewController:vc animated:YES];
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
