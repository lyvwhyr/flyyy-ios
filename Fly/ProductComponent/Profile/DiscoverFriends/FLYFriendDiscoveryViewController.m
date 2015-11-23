//
//  FLYFriendDiscoveryViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 11/22/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFriendDiscoveryViewController.h"
#import "FLYSearchBar.h"


@interface FLYFriendDiscoveryViewController () <FLYSearchBarDelegate>

@property (nonatomic) FLYSearchBar *searchBar;
@property (nonatomic) UITableView *tableView;

@end

@implementation FLYFriendDiscoveryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Discover Friends";
    self.view.backgroundColor = [UIColor tableHeaderGrey];
    
    self.searchBar = [FLYSearchBar new];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    [self updateViewConstraints];
}

-(void)updateViewConstraints
{
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 8);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(31));
    }];
    
    [super updateViewConstraints];
}

- (BOOL)isFullScreen
{
    return YES;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
