//
//  FLYLoginViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYLoginViewController.h"
#import "FLYIconButton.h"

@interface FLYLoginViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *phoneNumberView;
@property (nonatomic) FLYIconButton *countryCodeChooser;
@property (nonatomic) UITextField *phoneNumberTextField;
@property (nonatomic) UIImageView *passwordIcon;
@property (nonatomic) UITextField *passwordTextField;
@property (nonatomic) UILabel *forgetPasswordLabel;

@property (nonatomic) UIButton *loginButton;

@end

@implementation FLYLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel = [UILabel new];
    
}

@end
