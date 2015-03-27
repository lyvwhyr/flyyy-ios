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
#import "FLYLoginService.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"
#import "UICKeyChainStore.h"
#import "RNLoadingButton.h"
#import "PXAlertView.h"
#import "FLYSignupPasswordResetPhoneNumberViewController.h"

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
@property (nonatomic) UIButton *forgetPasswordButton;

@property (nonatomic) RNLoadingButton *loginButton;

@property (nonatomic, copy) NSString *formattedPhoneNumber;
@property (nonatomic, copy) NSString *unformattedPhoneNumber;
@property (nonatomic, copy) NSString *countryAreaCode;

//service
@property (nonatomic) FLYLoginService *loginService;

@end

@implementation FLYLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flyBlue];
    
    self.title = LOC(@"FLYLoginNavigationTitle");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};

    self.phoneNumberView = [UIView new];
    self.phoneNumberView.backgroundColor = [UIColor whiteColor];
    self.phoneNumberView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.phoneNumberView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.phoneNumberView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.phoneNumberView];
    
    self.loginButton = [[RNLoadingButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.loginButton.hideTextWhenLoading = NO;
    self.loginButton.loading = NO;
    self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.loginButton setActivityIndicatorAlignment:RNLoadingButtonAlignmentLeft];
    [self.loginButton setActivityIndicatorStyle:UIActivityIndicatorViewStyleGray forState:UIControlStateDisabled];
    self.loginButton.activityIndicatorEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
  
    
    [self.loginButton setEnabled:NO];
    [self.loginButton setTitle:LOC(@"FLYLoginButtonText") forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(_loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.countryCodeChooser = [[FLYIconButton alloc] initWithText:[FLYUtilities getCountryDialCode] textFont:[UIFont flyFontWithSize:16] textColor:[UIColor blackColor] icon:@"icon_login_country_code" isIconLeft:NO];
    [self.countryCodeChooser addTarget:self action:@selector(_countrySelectorSelected) forControlEvents:UIControlEventTouchUpInside];
    self.countryCodeChooser.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneNumberView addSubview:self.countryCodeChooser];
    self.countryAreaCode = [FLYUtilities getCountryDialCode];
    
    self.phoneNumberTextField = [UITextField new];
    self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.inputAccessoryView = self.loginButton;
    self.phoneNumberTextField.placeholder = LOC(@"FLYLoginDefaultPhoneNumberTextFieldText");
    [self.phoneNumberTextField addTarget:self action:@selector(_phoneNumberTextFieldDidChange)
                        forControlEvents:UIControlEventEditingChanged];
    self.phoneNumberTextField.delegate = self;
    [self.phoneNumberView addSubview:self.phoneNumberTextField];
    
    self.passwordView = [UIView new];
    self.passwordView.backgroundColor = [UIColor whiteColor];
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
    
    self.forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forgetPasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.forgetPasswordButton.titleLabel.font = [UIFont flyFontWithSize:16];
    [self.forgetPasswordButton setTitle:LOC(@"FLYLoginForgetPasswordText") forState:UIControlStateNormal];
    self.forgetPasswordButton.titleLabel.textColor = [UIColor whiteColor];
    [self.forgetPasswordButton addTarget:self action:@selector(_forgetPasswordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgetPasswordButton];
    
    [self _addConstraints];
    
    self.loginService = [FLYLoginService loginService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.phoneNumberTextField becomeFirstResponder];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)_addConstraints
{
    
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
    
    [self.forgetPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
}

- (void)_phoneNumberTextFieldDidChange
{
    if ([self.phoneNumberTextField.text length] > 0 && [self.passwordTextField.text length] > 0) {
        self.loginButton.backgroundColor = [UIColor flyButtonGreen];
        [self.loginButton setEnabled:YES];
    } else {
        self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
        [self.loginButton setEnabled:NO];
    }
    ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
    NSString *formattedNumber = [formatter stringForObjectValue:self.phoneNumberTextField.text];
    self.phoneNumberTextField.text = formattedNumber;
    
    self.formattedPhoneNumber = [NSString stringWithFormat:@"%@%@", self.countryAreaCode, formattedNumber];
}

- (void)_passwordTextFieldDidChange
{
    if ([self.phoneNumberTextField.text length] > 0 && [self.passwordTextField.text length] > 0) {
        self.loginButton.backgroundColor = [UIColor flyButtonGreen];
        [self.loginButton setEnabled:YES];
    } else {
        self.loginButton.backgroundColor = [UIColor flyColorFlySignupGrey];
        [self.loginButton setEnabled:NO];
    }
}

- (void)_forgetPasswordButtonTapped
{
    FLYSignupPasswordResetPhoneNumberViewController *vc = [FLYSignupPasswordResetPhoneNumberViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)_countrySelectorSelected
{
    FLYCountrySelectorViewController *vc = [FLYCountrySelectorViewController new];
    @weakify(self)
    vc.countrySelectedBlock = ^(NSString *countryDialCode) {
        @strongify(self)
        self.countryAreaCode = countryDialCode;
        [self.countryCodeChooser setLabelText:countryDialCode];
        
        ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
        NSString *formattedNumber = [formatter stringForObjectValue:self.phoneNumberTextField.text];
        self.formattedPhoneNumber = [NSString stringWithFormat:@"%@%@", self.countryAreaCode, formattedNumber];
    };
    FLYNavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)_loginButtonTapped
{
    [self.loginButton setTitle:@"Logging In" forState:UIControlStateDisabled];
    self.loginButton.enabled = NO;
    self.loginButton.loading = YES;
    
    //get phone number
    
    ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
    NSString *unformattedPhoneNumber;
    NSString *error;
    [formatter getObjectValue:&unformattedPhoneNumber forString:self.formattedPhoneNumber errorDescription:&error];
    
    //get password
    NSString *password = self.passwordTextField.text;
    
    FLYLoginUserSuccessBlock successBlock= ^(AFHTTPRequestOperation *operation, id responseObj) {
        self.loginButton.enabled = YES;
        self.loginButton.loading = NO;
        [self.loginButton setTitle:@"Login" forState:UIControlStateDisabled];
        
        NSString *authToken = [responseObj fly_stringForKey:@"auth_token"];
        if (!authToken) {
            UALog(@"Auth token is empty");
            return;
        }
        //store token
        [FLYAppStateManager sharedInstance].authToken = authToken;
        [UICKeyChainStore setString:[FLYAppStateManager sharedInstance].authToken forKey:kAuthTokenKey];
        
        //init current logged in user
        NSDictionary *userDict = [responseObj fly_dictionaryForKey:@"user"];
        if (!userDict) {
            UALog(@"User is empty");
            return;
        }
        FLYUser *user = [[FLYUser alloc] initWithDictionary:userDict];
        [FLYAppStateManager sharedInstance].currentUser = user;
        
        //save user id to NSUserDefault
        NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
        [defalut setObject:user.userId forKey:kLoggedInUserNsUserDefaultKey];
        [defalut synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    FLYLoginUserErrorBlock errorBlock= ^(id responseObj, NSError *error) {
        self.loginButton.enabled = YES;
        self.loginButton.loading = NO;
        [self.loginButton setTitle:@"Login" forState:UIControlStateDisabled];
        
        NSInteger code = [responseObj fly_integerForKey:@"code"];
        if (code == kInvalidPassword) {
            [PXAlertView showAlertWithTitle:LOC(@"FLYLoginWrongPassword")];
        } else if (code == kLoginPhoneNotFound) {
            [PXAlertView showAlertWithTitle:LOC(@"FLYLoginPhoneNumberNotFound")];
        }
    };
    
    [self.loginService loginWithPhoneNumber:unformattedPhoneNumber password:password success:successBlock error:errorBlock];
    
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
