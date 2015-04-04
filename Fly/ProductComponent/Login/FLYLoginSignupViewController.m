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

@property (nonatomic) UIView *logoView;
@property (nonatomic) UIImageView *logoImageView;
@property (nonatomic) UIView *logoSeparator;
@property (nonatomic) UILabel *logoText;

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
    
    self.backgroundImageView = [UIImageView new];
    self.backgroundImageView.image = [UIImage imageNamed:@"icon_login_background"];
    [self.view addSubview:self.backgroundImageView];
    
    self.logoView = [UIView new];
    [self.view addSubview:self.logoView];
    
    self.logoImageView = [UIImageView new];
    self.logoImageView.image = [UIImage imageNamed:@"icon_login_wings"];
    [self.logoView addSubview:self.logoImageView];
    
    self.logoSeparator = [UIView new];
    self.logoSeparator.backgroundColor = [UIColor whiteColor];
    [self.logoView addSubview:self.logoSeparator];
    
    UIFont *font = [UIFont flyFontWithSize:24];
    self.logoText = [UILabel new];
    self.logoText.text = LOC(@"FLYFlyy");
    self.logoText.font = font;
    self.logoText.textColor = [UIColor whiteColor];
    [self.logoView addSubview:self.logoText];
    
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(85));
        make.height.equalTo(@(35));
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-90);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.logoView);
        make.centerY.equalTo(self.logoView);
    }];
    
    [self.logoSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.logoImageView.mas_trailing).offset(5);
        make.top.equalTo(self.logoView).offset(3);
        make.width.equalTo(@(1));
        make.bottom.equalTo(self.logoView).offset(-3);
    }];
    
    [self.logoText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.logoSeparator.mas_trailing).offset(5);
        make.centerY.equalTo(self.logoView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.logoView.mas_bottom).offset(kTitleTopPadding);
    }];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
    return [UIColor clearColor];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor clearColor];
//    return [UIColor colorWithPatternImage: [UIImage imageNamed:@"icon_login_background"]];
}

@end
