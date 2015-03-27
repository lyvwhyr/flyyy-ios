//
//  FLYSignupEnterPasswordViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPasswordResetEnterPasswordViewController.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"
#import "PXAlertView.h"
#import "FLYUsersService.h"
#import "PXAlertView.h"
#import "UICKeyChainStore.h"
#import "FLYUser.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"

#define kTitleTopPadding 20

@interface FLYPasswordResetEnterPasswordViewController ()

@property (nonatomic, copy) NSString *username;

@property (nonatomic) UIView *inputPhoneView;
@property (nonatomic) UIImageView *inputIconView;
@property (nonatomic) UITextField *inputTextField;
@property (nonatomic) UIView *inputPasswordAgainView;
@property (nonatomic) UIImageView *inputPasswordAgainIconView;
@property (nonatomic) UITextField *inputPasswordAgainTextField;
@property (nonatomic) UILabel *passwordLengthHintLabel;
@property (nonatomic) UIButton *confirmButton;

//service
@property (nonatomic) FLYUsersService *usersService;

@end

@implementation FLYPasswordResetEnterPasswordViewController

- (instancetype)initWithUsername:(NSString *)username
{
    if (self = [super init]) {
        _username = username;
        _usersService = [FLYUsersService usersService];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor flyBlue];
    
    self.title = LOC(@"FLYResetPassword");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    self.inputPhoneView = [UIView new];
    self.inputPhoneView.backgroundColor = [UIColor whiteColor];
    self.inputPhoneView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.inputPhoneView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.inputPhoneView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.inputPhoneView];
    
    self.inputIconView = [UIImageView new];
    self.inputIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputIconView.image = [UIImage imageNamed:@"icon_login_password"];
    [self.inputIconView sizeToFit];
    [self.inputPhoneView addSubview:self.inputIconView];
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.confirmButton.backgroundColor = [UIColor flyButtonGreen];
    [self.confirmButton setTitle:LOC(@"FLYSignupPasswordOkButton") forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(_continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.inputTextField = [UITextField new];
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputTextField.inputAccessoryView = self.confirmButton;
    self.inputTextField.secureTextEntry = YES;
    self.inputTextField.placeholder = LOC(@"FLYResetPasswordNewPassword");
    [self.inputPhoneView addSubview:self.inputTextField];
    [self.inputTextField becomeFirstResponder];
    
    self.inputPasswordAgainView = [UIView new];
    self.inputPasswordAgainView.backgroundColor = [UIColor whiteColor];
    self.inputPasswordAgainView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputPasswordAgainView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.inputPasswordAgainView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.inputPasswordAgainView];
    
    self.inputPasswordAgainIconView = [UIImageView new];
    self.inputPasswordAgainIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputPasswordAgainIconView.image = [UIImage imageNamed:@"icon_login_password"];
    [self.inputPasswordAgainIconView sizeToFit];
    [self.inputPasswordAgainView addSubview:self.inputPasswordAgainIconView];
    
    self.inputPasswordAgainTextField = [UITextField new];
    self.inputPasswordAgainTextField.inputAccessoryView = self.confirmButton;
    self.inputPasswordAgainTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputPasswordAgainTextField.secureTextEntry = YES;
    self.inputPasswordAgainTextField.placeholder = LOC(@"FLYResetPasswordNewPasswordAgain");
    [self.inputPasswordAgainView addSubview:self.inputPasswordAgainTextField];
    
    self.passwordLengthHintLabel = [UILabel new];
    self.passwordLengthHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordLengthHintLabel.font = [UIFont flyFontWithSize:8];
    self.passwordLengthHintLabel.textColor = [UIColor whiteColor];
    self.passwordLengthHintLabel.text = LOC(@"FLYSignupPasswordLengthHint");
    [self.view addSubview:self.passwordLengthHintLabel];
    
    [self _addConstraints];
    
    

}

- (void)_addConstraints
{
    
    [self.inputPhoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.height.equalTo(@(44));
    }];
    
    [self.inputIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputPhoneView).offset(10);
        make.width.equalTo(@(CGRectGetWidth(self.inputIconView.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.inputIconView.bounds)));
        make.centerY.equalTo(self.inputPhoneView);
    }];
    
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputIconView.mas_trailing).offset(10);
        make.trailing.equalTo(self.inputPhoneView);
        make.centerY.equalTo(self.inputPhoneView);
    }];
    
    [self.inputPasswordAgainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputPhoneView.mas_bottom).offset(10);
        make.leading.equalTo(self.inputPhoneView);
        make.trailing.equalTo(self.inputPhoneView);
        make.height.equalTo(@(44));
    }];
    
    [self.inputPasswordAgainIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputPasswordAgainView).offset(10);
        make.width.equalTo(@(CGRectGetWidth(self.inputPasswordAgainIconView.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.inputPasswordAgainIconView.bounds)));
        make.centerY.equalTo(self.inputPasswordAgainView);
    }];
    
    [self.inputPasswordAgainTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputPasswordAgainIconView.mas_trailing).offset(10);
        make.trailing.equalTo(self.inputPasswordAgainView);
        make.centerY.equalTo(self.inputPasswordAgainView);
    }];
    
    [self.passwordLengthHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.inputTextField);
        make.top.equalTo(self.inputPhoneView.mas_bottom).offset(5);
    }];
}

- (void)_continueButtonTapped
{
    NSString *password = self.inputTextField.text;
    if (password.length < 6) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYSignupPasswordLengthError")];
        return;
    }
    
    NSString *passwordAgain = self.inputPasswordAgainTextField.text;
    if (![password isEqualToString:passwordAgain]) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYResetPasswordNewPasswordDoesNotMatch")];
        return;
    }
    
//    [self _createUserService];
}

- (void)_createUserService
{
    FLYCreateUserSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        UALog(@"success");
        if (!responseObj) {
            UALog(@"responseObj is empty");
        }
        if ([responseObj objectForKey:@"auth_token"]) {
            [FLYAppStateManager sharedInstance].authToken = [responseObj objectForKey:@"auth_token"];
            [UICKeyChainStore setString:[FLYAppStateManager sharedInstance].authToken forKey:kAuthTokenKey];
        }
        if ([responseObj objectForKey:@"user"]) {
            FLYUser *user = [[FLYUser alloc] initWithDictionary:[responseObj objectForKey:@"user"]];
            [FLYAppStateManager sharedInstance].currentUser = user;
            
            //save user id to NSUserDefault
            NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
            [defalut setObject:user.userId forKey:kLoggedInUserNsUserDefaultKey];
            [defalut synchronize];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    //TODO:error handling
    FLYCreateuserErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        if ([[responseObj objectForKey:@"code"] integerValue] == kUserNameAlreadyExist) {
            [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUserNameAlreadyExist")];
        } else {
            [PXAlertView showAlertWithTitle:[responseObj objectForKey:@"message"]];
        }
        
    };
    NSString *password = self.inputTextField.text;
    [self.usersService createUserWithPhoneHash:[FLYAppStateManager sharedInstance].phoneHash code:[FLYAppStateManager sharedInstance].confirmationCode userName:self.username password:password success:successBlock error:errorBlock];
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
