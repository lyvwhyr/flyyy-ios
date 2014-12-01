//
//  FLYGroupViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/30/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupViewController.h"
#import "FLYFeedViewController.h"

@interface FLYGroupViewController ()

@property (nonatomic) UIView *feedView;

@end

@implementation FLYGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    _feedView= [FLYFeedViewController new].view;
    [self.view addSubview:_feedView];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@(64));
//        make.leading.equalTo(@(0));
//        make.width.equalTo(@(414));
//        make.height.equalTo(@(672));
//    }];
    
    [super updateViewConstraints];
}

@end
