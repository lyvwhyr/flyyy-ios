//
//  FLYSignupEnterPasswordViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSignupEnterPasswordViewController.h"
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

@interface FLYSignupEnterPasswordViewController ()

@property (nonatomic, copy) NSString *username;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *inputPhoneView;
@property (nonatomic) UIImageView *inputIconView;
@property (nonatomic) UITextField *inputTextField;
@property (nonatomic) UILabel *passwordLengthHintLabel;
@property (nonatomic) UIButton *confirmButton;

//service
@property (nonatomic) FLYUsersService *usersService;

@end

@implementation FLYSignupEnterPasswordViewController

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
    
    self.title = LOC(@"FLYSignupPageTitle");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont flyFontWithSize:21];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = LOC(@"FLYSignupPasswordPageTitle");
    [self.view addSubview:self.titleLabel];
    
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
    self.inputTextField.placeholder = LOC(@"FLYSignupPasswordInputFieldHint");
    [self.inputPhoneView addSubview:self.inputTextField];
    [self.inputTextField becomeFirstResponder];
    
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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
    }];
    
    [self.inputPhoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
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
    [self _createUserService];
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
