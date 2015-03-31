//
//  FLYSettingsViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSettingsViewController.h"
#import "FLYSettingsCell.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"

#define kTableCellHeaderHeight 40

typedef NS_ENUM(NSInteger, FLYSettingsSectionType) {
    FLYSettingsLoveFlyy = 0,
    FLYSettingsSupport,
    FLYSettingsLogout
};

@interface FLYSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *settingsTableView;

@end

@implementation FLYSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = LOC(@"FLYYSettings");
    
    self.settingsTableView = [UITableView new];
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    self.settingsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.settingsTableView];
    
    [self _addViewConstraints];
}

- (FLYSettingsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYSettingsCellIdentifier";
    FLYSettingsCell *cell = [[FLYSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (indexPath.section == FLYSettingsLoveFlyy) {
        [cell configCellWithTitle:LOC(@"FLYSettingRateUs") hideRightArrow:YES];
    } else if (indexPath.section == FLYSettingsSupport) {
        if (indexPath.row == 0) {
            [cell configCellWithTitle:LOC(@"FLYSettingSendFeedback") hideRightArrow:NO];
        } else if (indexPath.row == 1) {
            [cell configCellWithTitle:LOC(@"FLYSettingRules") hideRightArrow:NO];
        } else if (indexPath.row == 2) {
            [cell configCellWithTitle:LOC(@"FLYSettingTermsOfSerivce") hideRightArrow:NO];
        } else if (indexPath.row == 3) {
            [cell configCellWithTitle:LOC(@"FLYSettingPrivacyPolicy") hideRightArrow:NO];
        }
        
    } else if (indexPath.section == FLYSettingsLogout) {
        [cell configCellWithTitle:LOC(@"FLYSettingLogout") hideRightArrow:YES];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)_addViewConstraints
{
    [self.settingsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == FLYSettingsLoveFlyy) {
        return 1;
    } else if (section == FLYSettingsSupport) {
        return 4;
    } else if (section == FLYSettingsLogout) {
        return 1;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kTableCellHeaderHeight)];
    customView.backgroundColor = [UIColor colorWithHexString:@"#F2EFEF"];
    UILabel * sectionHeader = [UILabel new];
    [customView addSubview:sectionHeader];
    
    CGRect frame = customView.frame;
    frame.origin.x += 25;
    frame.size.width = CGRectGetWidth(frame) - 25;
    sectionHeader.frame = frame;
    
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"Avenir-Black" size:15];
    sectionHeader.textColor = [UIColor flyBlue];
    if (section == FLYSettingsLoveFlyy) {
        sectionHeader.text = LOC(@"FLYYSettingLoveFlyy");
        return customView;
    } else if (section == FLYSettingsSupport){
        sectionHeader.text = LOC(@"FLYSettingSupport");
        return customView;
    } else if (section == FLYSettingsLogout) {
        sectionHeader.text = LOC(@"");
        return customView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableCellHeaderHeight;
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
