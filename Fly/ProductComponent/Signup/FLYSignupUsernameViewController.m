//
//  FLYSignupFieldViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSignupUsernameViewController.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"
#import "PXAlertView.h"
#import "FLYSignupEnterPasswordViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYUsernameService.h"
#import "NSDictionary+FLYAddition.h"

#define kTitleTopPadding 20


@interface FLYSignupUsernameViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *inputPhoneView;
@property (nonatomic) UIImageView *inputIconView;
@property (nonatomic) UITextField *inputTextField;
@property (nonatomic) UIButton *confirmButton;

//service
@property (nonatomic) FLYUsernameService *usernameService;

@end

@implementation FLYSignupUsernameViewController

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
    self.titleLabel.text = LOC(@"FLYSignupUsernameTitle");
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
    self.inputIconView.image = [UIImage imageNamed:@"icon_login_username"];
    [self.inputIconView sizeToFit];
    [self.inputPhoneView addSubview:self.inputIconView];
    
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.confirmButton.backgroundColor = [UIColor flyButtonGreen];
    [self.confirmButton setTitle:LOC(@"FLYSignupEnterPhoneNumberOKButton") forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(_continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.inputTextField = [UITextField new];
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputTextField.inputAccessoryView = self.confirmButton;
    self.inputTextField.placeholder = LOC(@"FLYSignupUsernameHint");
    [self.inputPhoneView addSubview:self.inputTextField];
    
    [self _addConstraints];
    
    self.usernameService = [FLYUsernameService usernameService];
    
    [[FLYScribe sharedInstance] logEvent:@"signup" section:@"pick_username" component:nil element:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.inputTextField becomeFirstResponder];
}

- (void)loadLeftBarButton
{
    self.navigationItem.hidesBackButton = YES;
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
}

- (void)_continueButtonTapped
{
    NSString *username = self.inputTextField.text;
    if ([username length] == 0 || username.length > kUsernameMaxLen) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUsernameLenError")];
        return;
    }
    
    if ([username rangeOfString:@" "].length != 0) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUsernameIncludeSpaceError")];
        return;
    }
    
    NSString *myRegex = @"[A-Z0-9a-z_]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex];
    BOOL valid = [predicate evaluateWithObject:username];
    if (!valid) {
        [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUsernameAlhpanumeric")];
        return;
    }
    [self _serverUsernameVerify:username];
}

- (void)_serverUsernameVerify:(NSString *)username
{
    FLYUsernameVerifySuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        if (!responseObj) {
            [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUsernameInuse")];
            return;
        }
        BOOL valid = [responseObj fly_boolForKey:@"valid" defaultValue:NO];
        if (valid) {
            FLYSignupEnterPasswordViewController *vc = [[FLYSignupEnterPasswordViewController alloc] initWithUsername:username];
            [self.navigationController pushViewController:vc animated:NO];
        } else {
            [PXAlertView showAlertWithTitle:LOC(@"FLYSignupUsernameInuse")];
        }
    };
    
    FLYUsernameVerifyErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        UALog(@"error");
    };
    [self.usernameService verifyUsername:username success:successBlock error:errorBlock];
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
