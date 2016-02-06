//
//  FLYOnboardingEnablePushNotificationViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 1/30/16.
//  Copyright © 2016 Fly. All rights reserved.
//

#import "FLYOnboardingEnablePushNotificationViewController.h"
#import "FLYMainViewController.h"

@interface FLYOnboardingEnablePushNotificationViewController ()

@property (nonatomic) UIButton *skipButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIButton *actionButton;

@end

@implementation FLYOnboardingEnablePushNotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.titleLabel = [UILabel new];
//    self.titleLabel.text = LOC(@"FLYFirtTimeEnablePushNotifiationTitle");
//    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.titleLabel.font = [UIFont flyBlackFontWithSize:42.0f];
//    self.titleLabel.textColor = [UIColor flyFirstTimeUserTextColor];
//    [self.titleLabel sizeToFit];
//    [self.view addSubview:self.titleLabel];
    
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
    self.descriptionLabel.font = [UIFont flyBlackFontWithSize:22.0f];
    self.descriptionLabel.textColor = [UIColor flyFirstTimeUserTextColor];
    [self.descriptionLabel sizeToFit];
    [self.view addSubview:self.descriptionLabel];
    
    self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionButton setTitle:LOC(@"FLYFirtTimeEnablePushNotifiationActionButtonText") forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.actionButton setBackgroundColor:[UIColor flyFirstTimeUserTextColor]];
    self.actionButton.titleLabel.font = [UIFont flyBlackFontWithSize:22];
    self.actionButton.layer.cornerRadius = 4.0f;
    self.actionButton.contentEdgeInsets = UIEdgeInsetsMake(12, 85, 12, 85);
    self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionButton addTarget:self action:@selector(_enablePushNotificationButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton sizeToFit];
    [self.view addSubview:self.actionButton];
    
     [self _addViewConstraints];
}

- (void)_addViewConstraints
{
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(23);
//        make.centerX.equalTo(self.view);
//    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.centerX.equalTo(self.view);
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.leading.lessThanOrEqualTo(self.view.mas_leading).offset(50);
        make.trailing.lessThanOrEqualTo(self.view.mas_trailing).offset(-50);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
}

- (void)_enablePushNotificationButtonTapped
{
    FLYMainViewController *vc = [FLYMainViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
