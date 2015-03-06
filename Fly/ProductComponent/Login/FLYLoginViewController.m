//
//  FLYLoginViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginViewController.h"
#import "FLYIconButton.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "ECPhoneNumberFormatter.h"
#import "FLYCountrySelectorViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"

#define kTitleTopPadding 20
#define kLeftIconWidth 50
#define kTextFieldLeftPadding 10
#define kTextFieldRightPadding 10

@interface FLYLoginViewController () <UITextFieldDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *phoneNumberView;
@property (nonatomic) FLYIconButton *countryCodeChooser;
@property (nonatomic) UITextField *phoneNumberTextField;

//password field
@property (nonatomic) UIView *passwordView;
@property (nonatomic) UIImageView *passwordIcon;
@property (nonatomic) UITextField *passwordTextField;
@property (nonatomic) UILabel *forgetPasswordLabel;

@property (nonatomic) UIButton *loginButton;

@property (nonatomic, copy) NSString *formattedPhoneNumber;
@property (nonatomic, copy) NSString *unformattedPhoneNumber;

@end

@implementation FLYLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = LOC(@"FLYLoginNavigationTitle");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
//    self.titleLabel = [UILabel new];
//    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.titleLabel.font = [UIFont flyFontWithSize:16];
//    self.titleLabel.textColor = [UIColor flyBlue];
//    self.titleLabel.text = LOC(@"FLYLoginTitle");
//    [self.view addSubview:self.titleLabel];
    
    
    self.phoneNumberView = [UIView new];
    self.phoneNumberView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.phoneNumberView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.phoneNumberView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.phoneNumberView];
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.loginButton setEnabled:NO];
    [self.loginButton setTitle:LOC(@"FLYLoginButtonText") forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(_loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.countryCodeChooser = [[FLYIconButton alloc] initWithText:[FLYUtilities getCountryDialCode] textFont:[UIFont flyFontWithSize:16] textColor:[UIColor blackColor] icon:@"icon_login_country_code" isIconLeft:NO];
    [self.countryCodeChooser addTarget:self action:@selector(_countrySelectorSelected) forControlEvents:UIControlEventTouchUpInside];
    self.countryCodeChooser.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneNumberView addSubview:self.countryCodeChooser];
    
    self.phoneNumberTextField = [UITextField new];
    self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.inputAccessoryView = self.loginButton;
    self.phoneNumberTextField.placeholder = LOC(@"FLYLoginDefaultPhoneNumberTextFieldText");
    [self.phoneNumberTextField addTarget:self action:@selector(_phoneNumberTextFieldDidChange)
                        forControlEvents:UIControlEventEditingChanged];
    self.phoneNumberTextField.delegate = self;
    [self.phoneNumberView addSubview:self.phoneNumberTextField];
    [self.phoneNumberTextField becomeFirstResponder];
    
    self.passwordView = [UIView new];
    self.passwordView.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.passwordView.layer.borderWidth = [FLYUtilities hairlineHeight];
    [self.view addSubview:self.passwordView];
    
    self.passwordIcon = [UIImageView new];
    self.passwordIcon.image = [UIImage imageNamed:@"icon_login_password"];
    [self.passwordView addSubview:self.passwordIcon];
    
    self.passwordTextField = [UITextField new];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordTextField.inputAccessoryView = self.loginButton;
    self.passwordTextField.placeholder = LOC(@"FLYLoginDefaultPasswordTextFieldText");
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.delegate = self;
    [self.passwordTextField addTarget:self action:@selector(_passwordTextFieldDidChange)
                        forControlEvents:UIControlEventEditingChanged];
    [self.passwordView addSubview:self.passwordTextField];
    
    self.forgetPasswordLabel = [UILabel new];
    self.forgetPasswordLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.forgetPasswordLabel.font = [UIFont flyFontWithSize:16];
    self.forgetPasswordLabel.textColor = [UIColor flyColorFlySignupGrey];
    self.forgetPasswordLabel.text = LOC(@"FLYLoginForgetPasswordText");
    [self.view addSubview:self.forgetPasswordLabel];
    
    [self _addConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)_addConstraints
{
    //title
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
//    }];
    
    //phone field
    [self.phoneNumberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view).offset(kTextFieldLeftPadding);
        make.height.equalTo(@(44));
        make.trailing.equalTo(self.view).offset(-kTextFieldRightPadding);
    }];
    
    [self.countryCodeChooser sizeToFit];
    [self.countryCodeChooser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneNumberView).offset(5);
        make.width.equalTo(@(kLeftIconWidth));
        make.centerY.equalTo(self.phoneNumberView);
    }];
    
    [self.phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.countryCodeChooser.mas_trailing).offset(6);
        make.trailing.equalTo(self.phoneNumberView);
        make.top.equalTo(self.phoneNumberView);
        make.bottom.equalTo(self.phoneNumberView);
    }];
    
    //password field
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneNumberView.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(kTextFieldLeftPadding);
        make.height.equalTo(@(44));
        make.trailing.equalTo(self.view).offset(-kTextFieldRightPadding);
    }];
    
    [self.passwordIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneNumberView).offset(15);
        make.centerY.equalTo(self.passwordView);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.countryCodeChooser.mas_trailing).offset(6);
        make.trailing.equalTo(self.passwordView);
        make.top.equalTo(self.passwordView);
        make.bottom.equalTo(self.passwordView);
    }];
    
    [self.forgetPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
}

- (void)_phoneNumberTextFieldDidChange
{
    if ([self.phoneNumberTextField.text length] > 0 && [self.passwordTextField.text length] > 0) {
        self.loginButton.backgroundColor = [UIColor flyBlue];
        [self.loginButton setEnabled:YES];
    } else {
        self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
        [self.loginButton setEnabled:NO];
    }
    ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
    NSString *formattedNumber = [formatter stringForObjectValue:self.phoneNumberTextField.text];
    self.phoneNumberTextField.text = formattedNumber;
    self.formattedPhoneNumber = formattedNumber;
}

- (void)_passwordTextFieldDidChange
{
    if ([self.phoneNumberTextField.text length] > 0 && [self.passwordTextField.text length] > 0) {
        self.loginButton.backgroundColor = [UIColor flyBlue];
        [self.loginButton setEnabled:YES];
    } else {
        self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
        [self.loginButton setEnabled:NO];
    }
}

- (void)_countrySelectorSelected
{
    FLYCountrySelectorViewController *vc = [FLYCountrySelectorViewController new];
    @weakify(self)
    vc.countrySelectedBlock = ^(NSString *countryDialCode) {
        @strongify(self)
        [self.countryCodeChooser setLabelText:countryDialCode];
    };
    FLYNavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)_loginButtonTapped
{
    
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
