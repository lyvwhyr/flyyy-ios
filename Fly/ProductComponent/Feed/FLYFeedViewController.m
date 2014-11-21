//
//  FLYFeedViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedViewController.h"

@interface FLYFeedViewController ()

@end

@implementation FLYFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewConstraints];
}

-(void)updateViewConstraints
{
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@0);
        make.top.equalTo(@(0));
        make.width.equalTo(@(kMainScreenWidth));
        make.height.equalTo(@(kContainerViewHeight));
    }];
    
    [super updateViewConstraints];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateViewConstraints];
    [FLYUtilities printAutolayoutTrace];
    
}

@end
