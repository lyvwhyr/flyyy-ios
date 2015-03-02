//
//  FLYSignupPhoneNumberViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/1/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSignupPhoneNumberViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYBarButtonItem.h"
#import "UIFont+FLYAddition.h"
#import "FLYIconButton.h"

#define kTitleTopPadding 50
#define kSubtitleTopPadding 50
#define kPhoneBackgroundImageViewTopPadding 10
#define kHintLabelPadding 10
#define kCountryCodeLabelWidth 44
#define kCountryCodeLabelHeight 22

@interface FLYSignupPhoneNumberViewController () <UITextFieldDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subTitleLabel;

//Country code and phone number
@property (nonatomic) UIView *phoneFieldView;
@property (nonatomic) FLYIconButton *countryCodeChooser;
@property (nonatomic) UIView *countryCodePhoneNumberSeparator;
@property (nonatomic) UITextField *phoneNumberTextField;
@property (nonatomic) UIButton *nextButton;

@property (nonatomic) UILabel *hintLabel;
@property (nonatomic) UIView *separator;
@property (nonatomic) UILabel *alreadyHaveAccountLabel;

@end

@implementation FLYSignupPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Navigation title
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LOC(@"FLYSignupPageTitle");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    self.titleLabel = [UILabel new];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont flyFontWithSize:21];
    self.titleLabel.textColor = [UIColor flyBlue];
    self.titleLabel.text = LOC(@"FLYSignupTitle");
    [self.view addSubview:self.titleLabel];
    
    self.subTitleLabel = [UILabel new];
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTitleLabel.font = [UIFont flyFontWithSize:21];
    self.subTitleLabel.textColor = [UIColor flyColorFlySignupGrey];
    self.subTitleLabel.text = LOC(@"FLYSignupSubTitle");
    [self.view addSubview:self.subTitleLabel];
    
    //country code and phone number
    self.phoneFieldView = [UIView new];
    self.phoneFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.phoneFieldView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.phoneFieldView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.phoneFieldView];
    
    self.countryCodeChooser = [[FLYIconButton alloc] initWithText:@"+23" textFont:[UIFont flyFontWithSize:16] textColor:[UIColor blackColor] icon:@"icon_login_country_code" isIconLeft:NO];
    self.countryCodeChooser.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneFieldView addSubview:self.countryCodeChooser];
    
    self.countryCodePhoneNumberSeparator = [UIView new];
    self.countryCodePhoneNumberSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    self.countryCodePhoneNumberSeparator.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.phoneFieldView addSubview:self.countryCodePhoneNumberSeparator];
    
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.nextButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.nextButton setTitle:LOC(@"FLYSignupEnterPhoneNumberOKButton") forState:UIControlStateNormal];
    
    
    self.phoneNumberTextField = [UITextField new];
    self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.inputAccessoryView = self.nextButton;
    self.phoneNumberTextField.placeholder = LOC(@"FLYSignupEnterPhoneNumberHint");
    [self.phoneNumberTextField addTarget:self action:@selector(_textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
    [self.phoneFieldView addSubview:self.phoneNumberTextField];
    
    self.hintLabel = [UILabel new];
    self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.hintLabel.font = [UIFont flyLightFontWithSize:12];
    self.hintLabel.textColor = [UIColor flyColorFlySignupGrey];
    self.hintLabel.text = LOC(@"FLYSignupHintText");
    [self.view addSubview:self.hintLabel];
    
    self.separator = [UIView new];
    self.separator.translatesAutoresizingMaskIntoConstraints = NO;
    self.separator.backgroundColor = [UIColor flyTabBarSeparator];
    [self.view addSubview:self.separator];
    
    self.alreadyHaveAccountLabel = [UILabel new];
    self.alreadyHaveAccountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.alreadyHaveAccountLabel.font = [UIFont flyFontWithSize:14];
    self.alreadyHaveAccountLabel.textColor = [UIColor flyBlue];
    self.alreadyHaveAccountLabel.text = LOC(@"FLYSignupAlreadyHaveAccount");
    [self.view addSubview:self.alreadyHaveAccountLabel];
    
    [self _addConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)_addConstraints
{
    CGFloat separatorHeight = 1.0/[FLYUtilities FLYMainScreenScale];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kSubtitleTopPadding);
    }];
    
    [self.phoneFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(kPhoneBackgroundImageViewTopPadding);
        make.width.equalTo(@(300));
        make.height.equalTo(@(44));
        make.centerX.equalTo(self.view);
        
    }];
    
    [self.countryCodeChooser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneFieldView).offset(5);
        make.centerY.equalTo(self.phoneFieldView);
    }];
    
    [self.countryCodePhoneNumberSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.countryCodeChooser.mas_trailing).offset(5);
        make.width.equalTo(@(separatorHeight));
        make.height.equalTo(self.phoneFieldView);
        make.centerY.equalTo(self.phoneFieldView);
    }];
    
    [self.phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.countryCodePhoneNumberSeparator.mas_trailing).offset(6);
        make.trailing.equalTo(self.phoneFieldView);
        make.top.equalTo(self.phoneFieldView);
        make.bottom.equalTo(self.phoneFieldView);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.phoneFieldView.mas_bottom).offset(kHintLabelPadding);
    }];
    
    [self.alreadyHaveAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(kNavBarHeight));
        make.bottom.equalTo(self.view);
    }];
    
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.width.equalTo(@(self.view.bounds.size.width));
        make.height.equalTo(@(separatorHeight));
        make.bottom.equalTo(self.alreadyHaveAccountLabel.mas_top);
    }];
}

#pragma mark - Text change
- (void)_textFieldDidChange
{
    if (self.phoneNumberTextField.text > 0) {
        self.nextButton.backgroundColor = [UIColor flyBlue];
    }
}


#pragma mark - Navigation bar
- (void)loadLeftBarButton
{
    @weakify(self)
    FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _backButtonTapped];
    };
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
