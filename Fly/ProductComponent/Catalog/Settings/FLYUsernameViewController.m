//
//  FLYUsernameViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/15/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUsernameViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYUser.h"
#import "UIFont+FLYAddition.h"

@interface FLYUsernameViewController () <UITextFieldDelegate>

@property (nonatomic) UILabel *tapToEditLabel;
@property (nonatomic) UITextField *usernameField;
@property (nonatomic) UIButton *confirmButton;

@end

@implementation FLYUsernameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Change your username";
    self.view.backgroundColor = [FLYUtilities colorWithHexString:@"#F2EFEF"];
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.confirmButton.backgroundColor = [UIColor flyButtonGreen];
    [self.confirmButton setTitle:LOC(@"FLYSettingSaveUsernameButton") forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(_saveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setEnabled:YES];
    
    self.usernameField = [UITextField new];
    self.usernameField.backgroundColor = [UIColor whiteColor];
    self.usernameField.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameField.text = [FLYAppStateManager sharedInstance].currentUser.userName;
    self.usernameField.delegate = self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    self.usernameField.leftView = paddingView;
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.inputAccessoryView = self.confirmButton;
    [self.usernameField becomeFirstResponder];
    [self.view addSubview:self.usernameField];
    
    [self _addConstraints];
}

- (void)_addConstraints
{
    [self.usernameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64 + 10);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
}

- (void)_saveButtonTapped
{
    
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
