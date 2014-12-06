//
//  FLYGroupsViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupListViewController.h"
#import "FLYGroupListTableViewCell.h"
#import "FLYGroupListSuggestTableViewCell.h"
#import "SCLAlertView.h"
#import "UIColor+FLYAddition.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYSingleGroupViewController.h"
#import "FLYMainViewController.h"
#import "FLYFeedViewController.h"
#import "FLYGroupViewController.h"

#define kSuggestGroupRow 0

@interface FLYGroupListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *groupsTabelView;

@property (nonatomic) NSMutableArray *groups;



@end

@implementation FLYGroupListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Groups";
    
    _groupsTabelView = [UITableView new];
    _groupsTabelView.translatesAutoresizingMaskIntoConstraints = NO;
    _groupsTabelView.backgroundColor = [UIColor clearColor];
    _groupsTabelView.delegate = self;
    _groupsTabelView.dataSource = self;
    [self.view addSubview:_groupsTabelView];
    
    _groups = [NSMutableArray new];
    [_groups addObject:@"Drugs and alcohol"];
    [_groups addObject:@"Rape"];
    [_groups addObject:@"Love confession"];
    [_groups addObject:@"LGBTQ"];
    [_groups addObject:@"Relationships"];
    
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Groups";
    [titleLabel sizeToFit];
    self.parentViewController.navigationItem.titleView = titleLabel;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)_addViewConstraints
{
//    [self.view removeConstraints:[self.view constraints]];
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.parentViewController.view);
//        make.leading.equalTo(self.parentViewController.view);
//        make.width.equalTo(@(CGRectGetWidth(self.parentViewController.view.bounds)));
//        make.height.equalTo(@(CGRectGetHeight(self.parentViewController.view.bounds) - kTabBarViewHeight));
//    }];
    
    [_groupsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
//    [super updateViewConstraints];
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIdentifier = @"FLYGroupListTableCellIdentifier";
        FLYGroupListSuggestTableViewCell *cell = (FLYGroupListSuggestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FLYGroupListSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *cellIdentifier = @"FLYGroupsViewControllerTableCellIdentifier";
    FLYGroupListTableViewCell *cell = (FLYGroupListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYGroupListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.groupName = [_groups objectAtIndex:indexPath.row - 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kSuggestGroupRow == indexPath.row) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        UITextField *textField = [alert addTextField:@"Enter group name"];
        
        [alert addButton:@"Suggest" actionBlock:^(void) {
            NSLog(@"Text value: %@", textField.text);
            
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.textLabel.text = @"Thank you";
            HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [HUD showInView:self.view];
            [HUD dismissAfterDelay:2.0];
        }];
        
        [alert showCustom:self image:[UIImage imageNamed:@"icon_feed_play"] color:[UIColor flyGreen] title:@"Suggest" subTitle:@"Do you want to suggest a new group? We are open to new ideas." closeButtonTitle:@"Cancel" duration:0.0f];
    } else {
//        FLYSingleGroupViewController *vc = [FLYSingleGroupViewController new];
//        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.navigationController pushViewController:vc animated:YES];
        
        FLYGroupViewController *vc = [FLYGroupViewController new];
        self.view.backgroundColor = [UIColor blueColor];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    FLYGroupListTableViewCell *cell = (FLYGroupListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

@end
