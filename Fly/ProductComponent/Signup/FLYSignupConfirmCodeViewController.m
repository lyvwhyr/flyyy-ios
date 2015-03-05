//
//  FLYSignupConfirmCodeViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/2/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSignupConfirmCodeViewController.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "FLYPhoneService.h"
#import "PXAlertView.h"
#import "PXAlertView+Customization.h"
#import "FLYSignupUsernameViewController.h"
#import "NSDictionary+FLYAddition.h"

#define kTitleTopPadding 20

@interface FLYSignupConfirmCodeViewController ()<UITextFieldDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *phoneIconView;
@property (nonatomic) UILabel *hintLabel;
@property (nonatomic) UIView *inputPhoneView;
@property (nonatomic) UIImageView *lockImageView;
@property (nonatomic) UITextField *verificationCodeField;
@property (nonatomic) UIButton *confirmButton;

//service
@property (nonatomic) FLYPhoneService *phoneService;

@end

@implementation FLYSignupConfirmCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont flyFontWithSize:21];
    self.titleLabel.textColor = [UIColor flyBlue];
    self.titleLabel.text = LOC(@"FLYConfirmCodeTitle");
    [self.view addSubview:self.titleLabel];
    
    self.phoneIconView = [UIImageView new];
    self.phoneIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneIconView.image = [UIImage imageNamed:@"icon_login_phone_text"];
    [self.view addSubview:self.phoneIconView];
    
    self.hintLabel = [UILabel new];
    self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.hintLabel.font = [UIFont flyFontWithSize:21];
    self.hintLabel.textColor = [UIColor flyColorFlySignupGrey];
    self.hintLabel.text = LOC(@"FLYConfirmCodeHint");
    [self.view addSubview:self.hintLabel];
    
    self.inputPhoneView = [UIView new];
    self.inputPhoneView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.inputPhoneView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.inputPhoneView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.inputPhoneView];
    
    self.lockImageView = [UIImageView new];
    self.lockImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lockImageView.image = [UIImage imageNamed:@"icon_login_verification_padlock"];
    [self.lockImageView sizeToFit];
    [self.inputPhoneView addSubview:self.lockImageView];
    
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.confirmButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.confirmButton setTitle:LOC(@"FLYConfirmCodeConfirmButton") forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(_confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.verificationCodeField = [UITextField new];
    self.verificationCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    self.verificationCodeField.keyboardType = UIKeyboardTypeNumberPad;
    self.verificationCodeField.delegate = self;
    self.verificationCodeField.inputAccessoryView = self.confirmButton;
    [self.verificationCodeField addTarget:self action:@selector(_textFieldDidChange)
                        forControlEvents:UIControlEventEditingChanged];
    [self.inputPhoneView addSubview:self.verificationCodeField];
    [self.verificationCodeField becomeFirstResponder];
    
    [self _addConstraints];
    
    NSString *phoneNumber = [FLYAppStateManager sharedInstance].phoneNumber;
    self.phoneService = [FLYPhoneService phoneServiceWithPhoneNumber:phoneNumber];
}

- (void)_addConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
    }];
    
    [self.phoneIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.phoneIconView.mas_bottom).offset(10);
    }];
    
    [self.inputPhoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hintLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.height.equalTo(@(44));
    }];
    
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.inputPhoneView).offset(10);
        make.width.equalTo(@(CGRectGetWidth(self.lockImageView.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.lockImageView.bounds)));
        make.centerY.equalTo(self.inputPhoneView);
    }];
    
    [self.verificationCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lockImageView.mas_trailing).offset(10);
        make.trailing.equalTo(self.inputPhoneView);
        make.centerY.equalTo(self.inputPhoneView);
    }];
}


- (void)_textFieldDidChange
{
    NSString *confirmCode = self.verificationCodeField.text;
    if (confirmCode.length == 6) {
        self.confirmButton.backgroundColor = [UIColor flyBlue];
        [self.confirmButton setEnabled:YES];
//        [self _verifyCode];
    }
}

- (void)_verifyCode
{
    FLYVerifyCodeSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        if (responseObj == nil) {
            [PXAlertView showAlertWithTitle:LOC(@"FLYInvalidVerificationCode")];
        } else {
            BOOL valid = [responseObj fly_boolForKey:@"valid" defaultValue:NO];
            if (valid) {
                FLYSignupUsernameViewController *vc = [FLYSignupUsernameViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [PXAlertView showAlertWithTitle:LOC(@"FLYInvalidVerificationCode")];
            }
        }
    };
    
    FLYVerifyCodeErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYInvalidVerificationCode")];
    };
    NSString *confirmCode = self.verificationCodeField.text;
    [self.phoneService serviceVerifyCode:confirmCode phonehash:[FLYAppStateManager sharedInstance].phoneHash phoneNumber:[FLYAppStateManager sharedInstance].phoneNumber success:successBlock error:errorBlock];
}

- (void)_confirmButtonTapped
{
    [self _verifyCode];
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
