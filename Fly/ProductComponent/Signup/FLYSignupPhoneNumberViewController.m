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
#import "ECPhoneNumberFormatter.h"
#import "FLYCountryListDatasource.h"
#import "FLYCountrySelectorViewController.h"
#import "PXAlertView.h"
#import "PXAlertView+Customization.h"
#import "FLYPhoneService.h"
#import "FLYSignupConfirmCodeViewController.h"
#import "NBPhoneNumberUtil.h"
#import "NSDictionary+FLYAddition.h"
#import "SVWebViewController.h"
#import "NSDictionary+FLYAddition.h"

#define kTitleTopPadding 10
#define kSubtitleTopPadding 50
#define kPhoneBackgroundImageViewTopPadding 20
#define kHintLabelPadding 10
#define kCountryCodeLabelWidth 44
#define kCountryCodeLabelHeight 22

@interface FLYSignupPhoneNumberViewController () <UITextFieldDelegate, NIAttributedLabelDelegate>

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subTitleLabel;

//Country code and phone number
@property (nonatomic) UIView *phoneFieldView;
@property (nonatomic) FLYIconButton *countryCodeChooser;
@property (nonatomic) UIView *countryCodePhoneNumberSeparator;
@property (nonatomic) UITextField *phoneNumberTextField;
@property (nonatomic) UIButton *nextButton;
@property (nonatomic) NIAttributedLabel *agreeTermsOfServiceLabel;

//@property (nonatomic) UILabel *hintLabel;
@property (nonatomic) UIView *separator;
@property (nonatomic) UILabel *alreadyHaveAccountLabel;

@property (nonatomic, copy) NSString *countryAreaCode;
@property (nonatomic, copy) NSString *formattedPhoneNumber;

@end

@implementation FLYSignupPhoneNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Navigation title
    self.view.backgroundColor = [UIColor flyBlue];
    self.title = LOC(@"FLYSignupPageTitle");
    UIFont *titleFont = [UIFont flyFontWithSize:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    self.subTitleLabel = [UILabel new];
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTitleLabel.font = [UIFont flyFontWithSize:21];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.subTitleLabel.text = LOC(@"FLYSignupSubTitle");
    [self.view addSubview:self.subTitleLabel];
    
    //country code and phone number
    self.phoneFieldView = [UIView new];
    self.phoneFieldView.backgroundColor = [UIColor whiteColor];
    self.phoneFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat borderWidth = 1.0/[FLYUtilities FLYMainScreenScale];
    self.phoneFieldView.layer.borderColor = [UIColor flyColorFlySignupGrey].CGColor;
    self.phoneFieldView.layer.borderWidth = borderWidth;
    [self.view addSubview:self.phoneFieldView];
    
    
    self.countryCodeChooser = [[FLYIconButton alloc] initWithText:[FLYUtilities getCountryDialCode] textFont:[UIFont flyFontWithSize:16] textColor:[UIColor blackColor] icon:@"icon_login_country_code" isIconLeft:NO];
    [self.countryCodeChooser addTarget:self action:@selector(_countrySelectorSelected) forControlEvents:UIControlEventTouchUpInside];
    self.countryCodeChooser.translatesAutoresizingMaskIntoConstraints = NO;
    [self.phoneFieldView addSubview:self.countryCodeChooser];
    
    self.countryCodePhoneNumberSeparator = [UIView new];
    self.countryCodePhoneNumberSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    self.countryCodePhoneNumberSeparator.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.phoneFieldView addSubview:self.countryCodePhoneNumberSeparator];
    
    self.countryAreaCode = [FLYUtilities getCountryDialCode];
    
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.nextButton.backgroundColor = [UIColor flyColorFlySignupGrey];
    [self.nextButton setTitle:LOC(@"FLYSignupEnterPhoneNumberOKButton") forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(_nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.phoneNumberTextField = [UITextField new];
    self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.inputAccessoryView = self.nextButton;
    self.phoneNumberTextField.placeholder = LOC(@"FLYSignupEnterPhoneNumberHint");
    [self.phoneNumberTextField addTarget:self action:@selector(_textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    [self.phoneFieldView addSubview:self.phoneNumberTextField];
    
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
    
    self.agreeTermsOfServiceLabel = [NIAttributedLabel new];
    self.agreeTermsOfServiceLabel.numberOfLines = 0;
    self.agreeTermsOfServiceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.agreeTermsOfServiceLabel.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    self.agreeTermsOfServiceLabel.textColor = [UIColor whiteColor];
    self.agreeTermsOfServiceLabel.font = [UIFont flyLightFontWithSize:12];
    
    self.agreeTermsOfServiceLabel.delegate = self;
    self.agreeTermsOfServiceLabel.autoDetectLinks = NO;
    self.agreeTermsOfServiceLabel.linkFont = [UIFont fontWithName:@"AvenirNext-Italic" size:12];
    self.agreeTermsOfServiceLabel.linkColor = [UIColor whiteColor];
    self.agreeTermsOfServiceLabel.text = LOC(@"FLYSignupAgreeTermsOfService");
    NSRange linkRange = [_agreeTermsOfServiceLabel.text rangeOfString:LOC(@"FLYSignupTermsOfServiceLinkText")];
    NSRange linkRange2 = [_agreeTermsOfServiceLabel.text rangeOfString:LOC(@"FLYSignupPrivacyPolicyLinkText")];
    
    [self.agreeTermsOfServiceLabel addLink:[NSURL URLWithString:kTermsOfServiceURL]
                                 range:linkRange];
    [self.agreeTermsOfServiceLabel addLink:[NSURL URLWithString:kPrivacyPolicyURL]
                                 range:linkRange2];
    [self.view addSubview:self.agreeTermsOfServiceLabel];
    
    [self _addConstranits];
    
    [[FLYScribe sharedInstance] logEvent:@"signup" section:@"enter_phone" component:nil element:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.phoneNumberTextField becomeFirstResponder];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)_addConstranits
{
    CGFloat separatorHeight = 1.0/[FLYUtilities FLYMainScreenScale];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kTitleTopPadding + kStatusBarHeight + kNavBarHeight);
    }];
    
    [self.phoneFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(kPhoneBackgroundImageViewTopPadding);
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.height.equalTo(@(44));
        
    }];
    
    [self.countryCodeChooser sizeToFit];
    [self.countryCodeChooser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneFieldView).offset(5);
        make.width.equalTo(@(50));
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
    
    [self.agreeTermsOfServiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneFieldView);
        make.top.equalTo(self.phoneFieldView.mas_bottom).offset(10);
        make.trailing.equalTo(self.phoneFieldView);
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)_countrySelectorSelected
{
    FLYCountrySelectorViewController *vc = [FLYCountrySelectorViewController new];
    @weakify(self)
    vc.countrySelectedBlock = ^(NSString *countryDialCode) {
        @strongify(self)
        [self.countryCodeChooser setLabelText:countryDialCode];
        self.countryAreaCode = countryDialCode;
    };
    FLYNavigationController *nav = [[FLYNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Text change
- (void)_textFieldDidChange
{
    if ([self.phoneNumberTextField.text length] > 0) {
        self.nextButton.backgroundColor = [UIColor flyButtonGreen];
    }
    ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
    NSString *formattedNumber = [formatter stringForObjectValue:self.phoneNumberTextField.text];
    self.phoneNumberTextField.text = formattedNumber;
    self.formattedPhoneNumber = formattedNumber;
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_nextButtonTapped
{
    NSString *phoneNumber = [NSString stringWithFormat:@"%@ %@", self.countryAreaCode, self.formattedPhoneNumber];
    
    BOOL phoneVerificationEnabled = [[FLYAppStateManager sharedInstance].configs fly_boolForKey:@"phoneVerificationEnabled" defaultValue:NO];
    
    if (phoneVerificationEnabled) {
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        NBPhoneNumber *myNumber = [phoneUtil parse:phoneNumber
                                     defaultRegion:nil error:&anError];
        BOOL isValid = [phoneUtil isValidNumber:myNumber];
        if (!isValid) {
            [PXAlertView showAlertWithTitle:@"Phone number is not valid"];
            return;
        }
    }
    
    @weakify(self)
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:LOC(@"FLYSignupPhoneNumberConfirmationAlert")
                                                     message: phoneNumber
                                                 cancelTitle:@"Cancel"
                                                  otherTitle:@"Yes"
                                                 contentView:nil
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      @strongify(self)
                                                      if (buttonIndex == 1) {
                                                          ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
                                                          NSString *unformattedPhoneNumber;
                                                          NSString *error;
                                                          [formatter getObjectValue:&unformattedPhoneNumber forString:phoneNumber errorDescription:&error];
                                                          
                                                          [FLYAppStateManager sharedInstance].phoneNumber = unformattedPhoneNumber;
                                                          FLYPhoneService *service = [FLYPhoneService phoneServiceWithPhoneNumber:phoneNumber];
                                                          [service serviceSendCodeWithPhone:unformattedPhoneNumber isPasswordReset:NO success:^(AFHTTPRequestOperation *operation, id responseObj) {
                                                              if (responseObj) {
                                                                  [FLYAppStateManager sharedInstance].phoneHash = [responseObj objectForKey:@"phone_hash"];
                                                                  FLYSignupConfirmCodeViewController *vc = [FLYSignupConfirmCodeViewController new];
                                                                  [self.navigationController pushViewController:vc animated:YES];
                                                              } else {
                                                                  PXAlertView *errorAlert = [PXAlertView showAlertWithTitle:@"Something went wrong. Please try again later"];
                                                                  [errorAlert useDefaultIOS7Style];
                                                              }
                                                              
                                                          } error:^(id responseObj, NSError *error) {
                                                              if (responseObj && [responseObj isKindOfClass:[NSDictionary class]]) {
                                                                  NSInteger code = [responseObj fly_integerForKey:@"code"];
                                                                  if (code == kPhoneNumberAlreadyClaimed) {
                                                                      [PXAlertView showAlertWithTitle:LOC(@"FLYSignupPhoneNumberAlreadyExist")];
                                                                  } else if(code == kNotValidPhoneNumber) {
                                                                      [PXAlertView showAlertWithTitle:LOC(@"FLYSignupNotValidPhoneNumber")];
                                                                  } else {
                                                                      [[Mixpanel sharedInstance]  track:kTrackingEventClientError properties:@{kTrackingPropertyEndpointName:EP_PHONE,kTrackingPropertyServerResponse:responseObj}];
                                                                  }
                                                              } else {
                                                                  [[Mixpanel sharedInstance]  track:kTrackingEventClientError properties:@{kTrackingPropertyEndpointName:EP_PHONE, kTrackingPropertyServerResponse:@"empty response obj or not NSDictionary"}];
                                                              }
                                                          }];
                                                      }
                                                  }];
    [alertView useDefaultIOS7Style];
}

#pragma mark - NIAttributedLabelDelegate
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSURL *url = result.URL;
    if (url) {
        NSString *urlString = [url absoluteString];
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:urlString];
        [self.navigationController pushViewController:webViewController animated:NO];
    }
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
