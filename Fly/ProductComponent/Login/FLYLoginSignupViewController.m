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

@interface FLYLoginSignupViewController ()

@property (nonatomic) UIView *loginBgView;
@property (nonatomic) UILabel *loginLabel;
@property (nonatomic) UIView *signupBgView;
@property (nonatomic) UILabel *signupLabel;

@end

@implementation FLYLoginSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide the 1px bottom line in navigation bar
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    self.loginBgView = [UIView new];
    self.loginBgView.backgroundColor = [UIColor flyLoginBgColor];
    self.loginBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *loginTapGr = [UITapGestureRecognizer new];
    [loginTapGr addTarget:self action:@selector(loginTapped)];
    [self.loginBgView addGestureRecognizer:loginTapGr];
    
    [self.view addSubview:self.loginBgView];
    
    UIFont *font = [UIFont flyBlackFontWithSize:26];
    self.loginLabel = [UILabel new];
    self.loginLabel.text = @"LOGIN";
    self.loginLabel.font = font;
    self.loginLabel.textColor = [UIColor whiteColor];
    [self.loginLabel sizeToFit];
    [self.view addSubview:self.loginLabel];
    

    self.signupBgView = [UIView new];
    self.signupBgView.backgroundColor = [UIColor flySignupBgColor];
    [self.view addSubview:self.signupBgView];
    
    self.signupBgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *signupTapGr = [UITapGestureRecognizer new];
    [signupTapGr addTarget:self action:@selector(signupTapped)];
    [self.signupBgView addGestureRecognizer:signupTapGr];
    
    self.signupLabel = [UILabel new];
    self.signupLabel.text = @"SIGNUP";
    self.signupLabel.font = font;
    self.signupLabel.textColor = [UIColor whiteColor];
    [self.signupLabel sizeToFit];
    [self.view addSubview:self.signupLabel];
    
    [[FLYScribe sharedInstance] logEvent:@"login_signup_page" section:nil component:nil element:nil action:@"impression"];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Navigation bar

// Don't show left bar button
- (void)loadLeftBarButton
{

}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_addViewConstraints
{
    
    CGFloat halfScreen = CGRectGetHeight(self.view.bounds) / 2.0f;
    
    [self.loginBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(halfScreen));
    }];
    
    [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loginBgView);
        make.centerY.equalTo(self.loginBgView);
    }];
    
    [self.signupBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBgView.mas_bottom);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(halfScreen));
    }];
    
    [self.signupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.signupBgView);
        make.centerY.equalTo(self.signupBgView);
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

- (void)_exitButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signupTapped
{
    FLYSignupPhoneNumberViewController *vc = [FLYSignupPhoneNumberViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginTapped
{
    FLYLoginViewController *vc = [FLYLoginViewController new];
    vc.canGoBack = YES;
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
