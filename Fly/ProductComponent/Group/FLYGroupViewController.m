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

@property (nonatomic) FLYFeedViewController *feedViewController;

@end

@implementation FLYGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _feedViewController = [FLYFeedViewController new];
    [self.view addSubview:_feedViewController.view];
    _feedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    [FLYUtilities printAutolayoutTrace];
}

- (void)updateViewConstraints
{
    
    [self.view removeConstraints:self.view.constraints];
//    [_feedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view);
//        make.leading.equalTo(self.view);
//        make.width.equalTo(self.view);
//        make.height.equalTo(self.view);
//    }];
    [super updateViewConstraints];
}

@end
