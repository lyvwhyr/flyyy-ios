//
//  FLYSingleGroupViewController.m
//  Fly
//
//  Created by Xingxing Xu on 12/1/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYSingleGroupViewController.h"
#import "FLYFeedViewController.h"

@interface FLYSingleGroupViewController ()

@property (nonatomic) FLYFeedViewController *feedViewController;

@end

@implementation FLYSingleGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _feedViewController = [FLYFeedViewController new];
//    [self.view addSubview:_feedViewController.view];
//    _feedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor blueColor];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view layoutIfNeeded];
    [FLYUtilities printAutolayoutTrace];
}

//- (void)updateViewConstraints
//{
//    [self.view removeConstraints:self.view.constraints];
//    [_feedViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view);
//            make.leading.equalTo(self.view);
//            make.width.equalTo(self.view);
//            make.height.equalTo(self.view);
//        }];
//    [super updateViewConstraints];
//}


@end
