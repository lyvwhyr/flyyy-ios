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
#import "FLYMainViewController.h"
#import "FLYFeedViewController.h"
#import "FLYGroupViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYGroupListCell.h"
#import "FLYGroupManager.h"
#import "FLYGroup.h"
#import "Dialog.h"

#define kSuggestGroupRow 0

@interface FLYGroupListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *groupsTabelView;

@property (nonatomic) NSArray *groups;



@end

@implementation FLYGroupListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOC(@"FLYTags");
    
    _groupsTabelView = [UITableView new];
    _groupsTabelView.translatesAutoresizingMaskIntoConstraints = NO;
    _groupsTabelView.backgroundColor = [UIColor clearColor];
    _groupsTabelView.delegate = self;
    _groupsTabelView.dataSource = self;
    _groupsTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_groupsTabelView];
    
    _groups = [NSArray arrayWithArray:[FLYGroupManager sharedInstance].groupList];
    
    [self _addViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = LOC(@"FLYTags");
    [titleLabel sizeToFit];
    self.parentViewController.navigationItem.titleView = titleLabel;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title = LOC(@"FLYTags");
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
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
        UITableViewCell *cell;
        NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d%d", @"identifier", (int)indexPath.section, (int)indexPath.row];
        cell = [[FLYGroupListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        FLYGroupListCell *chooseGroupCell = (FLYGroupListCell *)cell;
        [chooseGroupCell.checkButton setImage:[UIImage imageNamed:@"icon_suggest_group"] forState:UIControlStateNormal];
        chooseGroupCell.isFirst = YES;
        chooseGroupCell.groupName = LOC(@"FLYSuggestATag");
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d%d", @"identifier", (int)indexPath.section, (int)indexPath.row];
    cell = [[FLYGroupListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    FLYGroupListCell *chooseGroupCell = (FLYGroupListCell *)cell;
    FLYGroup *group = [_groups objectAtIndex:(indexPath.row - 1)];
    chooseGroupCell.groupName = group.groupName;
    cell = chooseGroupCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = ((FLYGroup *)[self.groups objectAtIndex:indexPath.row]).groupName;
    [[FLYScribe sharedInstance] logEvent:@"group_list" section:groupName  component:nil element:nil action:@"click"];
    
    if (kSuggestGroupRow == indexPath.row) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        UITextField *textField = [alert addTextField:LOC(@"FLYEnterTagNamePopupHintText")];
        
        [alert addButton:@"Suggest" actionBlock:^(void) {
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.textLabel.text = @"Thank you";
            HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [HUD showInView:self.view];
            [HUD dismissAfterDelay:1.0];
        }];
        
        [alert showCustom:self image:[UIImage imageNamed:@"icon_homefeed_playgreenempty"] color:[UIColor flyBlue] title:@"Suggest" subTitle:@"Do you want to suggest a new tag? We are open to new ideas." closeButtonTitle:@"Cancel" duration:0.0f];
    } else {
        //Because the first cell is "Suggest a tag", we need to use indexPath.row - 1
        FLYGroup *group = self.groups[indexPath.row - 1];
        FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
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
