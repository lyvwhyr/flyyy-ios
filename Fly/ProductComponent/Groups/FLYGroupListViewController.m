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
    [_groups addObject:@"Sexually Assaulted"];
    [_groups addObject:@"Funny Stories"];
    [_groups addObject:@"Guilt Trips"];
    [_groups addObject:@"My Fantasies"];
    [_groups addObject:@"My Crushes"];
    
    [_groups addObject:@"Feeling Blue"];
    [_groups addObject:@"Jokes"];
    [_groups addObject:@"My Confessions"];
    [_groups addObject:@"My ex is.."];
    [_groups addObject:@"Men are.."];
    
    [_groups addObject:@"Women are.."];
    [_groups addObject:@"Dating Advice"];
    [_groups addObject:@"Greatest Fears"];
    [_groups addObject:@"Accomplishments"];
    [_groups addObject:@"Breaking up"];
    [_groups addObject:@"Lonely"];
    [_groups addObject:@"In the closet"];
    [_groups addObject:@"Help!"];
    [_groups addObject:@"Happy"];
    [_groups addObject:@"Bad Day"];
    [_groups addObject:@"Good Day"];
    [_groups addObject:@"My Purpose"];
    [_groups addObject:@"Fitting In"];
    [_groups addObject:@"Lies"];
    [_groups addObject:@"Betrayals"];

    [_groups addObject:@"Shameful Past"];
    [_groups addObject:@"My Dreams"];
    [_groups addObject:@"Mood Swings"];
    [_groups addObject:@"Stress"];
    [_groups addObject:@"Lies"];
    [_groups addObject:@"Betrayals"];
    [_groups addObject:@"Can't Orgasm"];
    [_groups addObject:@"Family Pressure"];
    [_groups addObject:@"Forgiveness"];
    [_groups addObject:@"Karma"];
    [_groups addObject:@"Success Stories "];
    [_groups addObject:@"Ask Flyy"];
    [_groups addObject:@"I discovered"];
    [_groups addObject:@"First Kiss"];
    [_groups addObject:@"Lies"];
    [_groups addObject:@"Betrayals"];
    [_groups addObject:@"Loosing Virginity"];
    [_groups addObject:@"Still A Virgin"];
    [_groups addObject:@"Disordered Eating"];
    [_groups addObject:@"Can't Sleep"];
    [_groups addObject:@"Stepmother"];
    [_groups addObject:@"Stepfather"];
    [_groups addObject:@"Douchebag"];
    [_groups addObject:@"Womanizers"];
    [_groups addObject:@"Nightmares"];
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
    return;
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
        
        [alert showCustom:self image:[UIImage imageNamed:@"icon_feed_play"] color:[UIColor flyBlue] title:@"Suggest" subTitle:@"Do you want to suggest a new group? We are open to new ideas." closeButtonTitle:@"Cancel" duration:0.0f];
    } else {
//        FLYSingleGroupViewController *vc = [FLYSingleGroupViewController new];
//        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.navigationController pushViewController:vc animated:YES];
        
        FLYGroupViewController *vc = [FLYGroupViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    FLYGroupListTableViewCell *cell = (FLYGroupListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

@end
