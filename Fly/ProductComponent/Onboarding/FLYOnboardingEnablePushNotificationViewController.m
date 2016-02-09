//
//  FLYOnboardingEnablePushNotificationViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 1/30/16.
//  Copyright © 2016 Fly. All rights reserved.
//

#import "FLYOnboardingEnablePushNotificationViewController.h"
#import "FLYMainViewController.h"
#import "SDVersion.h"
#import "FLYPushNotificationManager.h"
#import "FLYBarButtonItem.h"
#import "FLYNavigationController.h"

@interface FLYOnboardingEnablePushNotificationViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIButton *actionButton;

@property (nonatomic) BOOL hasPushedToNewVC;

@end

@implementation FLYOnboardingEnablePushNotificationViewController


#pragma mark - UIViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _addObservers];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self _shouldShowTitle]) {
        self.titleLabel = [UILabel new];
        self.titleLabel.text = LOC(@"FLYFirtTimeEnablePushNotifiationTitle");
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont flyBlackFontWithSize:42.0f];
        self.titleLabel.textColor = [UIColor flyFirstTimeUserTextColor];
        [self.titleLabel sizeToFit];
        [self.view addSubview:self.titleLabel];
    }
    
    self.imageView = [UIImageView new];
    self.imageView.image = [UIImage imageNamed:@"push_notification_onboarding_hint"];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView sizeToFit];
    [self.view addSubview:self.imageView];
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.text = LOC(@"FLYFirtTimeEnablePushNotifiationDescription");
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.font = [UIFont flyBlackFontWithSize:18.0f];
    self.descriptionLabel.textColor = [UIColor flyFirstTimeUserTextColor];
    [self.descriptionLabel sizeToFit];
    [self.view addSubview:self.descriptionLabel];
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionButton setTitle:LOC(@"FLYFirtTimeEnablePushNotifiationActionButtonText") forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton setBackgroundColor:[UIColor flyFirstTimeUserTextColor]];
    self.actionButton.titleLabel.font = [UIFont flyBlackFontWithSize:22];
    self.actionButton.layer.cornerRadius = 4.0f;
    if ([SDVersion deviceSize] >= Screen4Dot7inch) {
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(12, 65, 12, 65);
    } else {
        self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(12, 40, 12, 40);
    }
    
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionButton addTarget:self action:@selector(_enablePushNotificationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton sizeToFit];
    [self.view addSubview:self.actionButton];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.view removeGestureRecognizer:self.navigationController.interactivePopGestureRecognizer];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - Add observers

- (void)_addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pushVC) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pushVC) name:kPushNotificationEnabled object:nil];
}

- (void)_addViewConstraints
{
    if ([self _shouldShowTitle]) {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset([self _titleTopPadding]);
            make.centerX.equalTo(self.view);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset([self _imageTopPadding]);
            make.centerX.equalTo(self.view);
        }];
    } else {
        CGFloat height = CGRectGetHeight(self.imageView.bounds);
        CGFloat width = CGRectGetWidth(self.imageView.bounds);
        if ([SDVersion deviceSize] == Screen4inch) {
            height = (int)(height/1.2);
            width = (int)(width/1.2);
        } else {
            // 3 inch
            height = (int)(height/1.6);
            width = (int)(width/1.6);
        }
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset([self _imageTopPadding]);
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
            make.centerX.equalTo(self.view);
        }];
    }
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset([self _descrptionLabelTopPadding]);
        make.centerX.equalTo(self.view);
        make.leading.lessThanOrEqualTo(self.view.mas_leading).offset(35);
        make.trailing.lessThanOrEqualTo(self.view.mas_trailing).offset(-35);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset([self _actionButtonTopPadding]);
        make.centerX.equalTo(self.view);
    }];
}


- (BOOL)_shouldShowTitle
{
    if([SDVersion deviceSize] >= Screen4Dot7inch) {
        return YES;
    }
    return NO;
}

- (CGFloat)_titleTopPadding
{
    CGFloat padding = 0;
    DeviceSize deviceSize = [SDVersion deviceSize];
    if (deviceSize >= Screen4Dot7inch) {
        padding = 50;
    }
    return padding;
}

- (CGFloat)_imageTopPadding
{
    CGFloat padding = 0;
    DeviceSize deviceSize = [SDVersion deviceSize];
    if (deviceSize >= Screen4Dot7inch) {
        padding = 30;
    } else {
        padding = 44;
    }
    return padding;
}

- (CGFloat)_descrptionLabelTopPadding
{
    CGFloat padding = 0;
    DeviceSize deviceSize = [SDVersion deviceSize];
    if (deviceSize >= Screen5Dot5inch) {
        padding = 33;
    } else {
        padding = 33/1.375;
    }
    return padding;
}

- (CGFloat)_actionButtonTopPadding
{
    CGFloat padding = 0;
    DeviceSize deviceSize = [SDVersion deviceSize];
    if (deviceSize >= Screen5Dot5inch) {
        padding = 33;
    } else {
        padding = 33/1.375;
    }
    return padding;
}

- (void)_enablePushNotificationButtonTapped
{
    [FLYPushNotificationManager registerPushNotification];
    
    // ios 7
    if (iOSVersionLessThan(@"8")) {
        [self _pushVC];
    }
}

- (void)_pushVC
{
    if (self.hasPushedToNewVC) {
        return;
    }
    FLYMainViewController *vc = [FLYMainViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    self.hasPushedToNewVC = YES;
}

@end
