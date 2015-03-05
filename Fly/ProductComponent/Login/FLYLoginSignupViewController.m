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

@interface FLYLoginSignupViewController ()

@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UIButton *signupButton;

@end

@implementation FLYLoginSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.loginButton setTitle:LOC(@"FLYLoginButtonText") forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(_loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [UIColor flyBlue];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.signupButton addTarget:self action:@selector(_signupButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.signupButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.signupButton setTitle:LOC(@"FLYSignupButtonText") forState:UIControlStateNormal];
    [self.view addSubview:self.signupButton];
    
    [self _addViewConstraints];
}

- (void)_addViewConstraints
{
    [self.signupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@(64));
        make.width.equalTo(self.view);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.bottom.equalTo(self.signupButton.mas_top);
        make.height.equalTo(@(64));
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

@end
