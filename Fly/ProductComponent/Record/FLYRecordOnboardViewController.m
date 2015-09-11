//
//  FLYRecordOnboardViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 7/19/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYRecordOnboardViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYBarButtonItem.h"
#import "TTTAttributedLabel.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"
#import "FLYAudioManager.h"
#import "FLYRecordViewController.h"
#import "FLYNavigationController.h"


@interface FLYRecordOnboardViewController ()

@property (nonatomic) TTTAttributedLabel *explanationLabel;
@property (nonatomic) TTTAttributedLabel *beAuthenticLabel;
@property (nonatomic) TTTAttributedLabel *noAbusiveContentLabel;

@end

@implementation FLYRecordOnboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _explanationLabel = [TTTAttributedLabel new];
    _explanationLabel.numberOfLines = 0;
    _explanationLabel.font = [UIFont fontWithName:@"Avenir-Book" size:18];
    _explanationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _explanationLabel.text = LOC(@"FLYRecordOnboardExplanationText");
    [_explanationLabel sizeToFit];
    [self.view addSubview:_explanationLabel];
    
    _beAuthenticLabel = [TTTAttributedLabel new];
    _beAuthenticLabel.numberOfLines = 0;
    _beAuthenticLabel.font = [UIFont fontWithName:@"Avenir-Book" size:18];
    _beAuthenticLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _beAuthenticLabel.text = LOC(@"FLYRecordOnboardBeAuthenticRuleText");
    [_beAuthenticLabel sizeToFit];
    [self.view addSubview:_beAuthenticLabel];
    
    _noAbusiveContentLabel = [TTTAttributedLabel new];
    _noAbusiveContentLabel.numberOfLines = 0;
    _noAbusiveContentLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17];
    _noAbusiveContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noAbusiveContentLabel.text = LOC(@"FLYRecordOnboardNoAbusiveContentText");
    [_noAbusiveContentLabel sizeToFit];
    [self.view addSubview:_noAbusiveContentLabel];
    
    [self _addViewConstraints];
}

- (void)loadRightBarButton
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Agree" style:UIBarButtonItemStylePlain target:self action:@selector(_agreeTapped)];
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont flyFontWithSize:18]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)_agreeTapped
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRecordingAgreeRulesKey];
    
    [self dismissViewControllerAnimated:NO completion:^{
           [[NSNotificationCenter defaultCenter] postNotificationName:kAgreedRecordRuleNotification object:self];
    }];
}

- (void)_addViewConstraints
{
    [self.explanationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 20);
        make.leading.equalTo(self.view).offset(15);
        make.trailing.lessThanOrEqualTo(self.view).offset(-15);
    }];
    
    [self.beAuthenticLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.explanationLabel.mas_bottom).offset(20);
        make.leading.equalTo(self.explanationLabel);
        make.trailing.lessThanOrEqualTo(self.view).offset(-15);
    }];
    
    [self.noAbusiveContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beAuthenticLabel.mas_bottom).offset(20);
        make.leading.equalTo(self.explanationLabel);
        make.trailing.lessThanOrEqualTo(self.view).offset(-15);
    }];
    
}

#pragma mark - Navigation bar

- (void)loadLeftBarButton
{
    FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
    @weakify(self)
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    self.navigationItem.leftBarButtonItem = barItem;
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
