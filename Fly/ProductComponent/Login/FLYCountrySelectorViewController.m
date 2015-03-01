//
//  FLYCountrySelectorViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYCountrySelectorViewController.h"
#import "FLYCountryListDatasource.h"
#import "FLYBarButtonItem.h"
#import "FLYCountrySelectorTableViewCell.h"
#import "UIColor+FLYAddition.h"

@interface FLYCountrySelectorViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray *popularCountries;
@property (nonatomic) NSArray *allCountries;

@end

@implementation FLYCountrySelectorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOC(@"FLYCountryCodeTitle");
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.tableView = [UITableView new];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    FLYCountryListDatasource *countryDataSource = [FLYCountryListDatasource new];
    self.popularCountries = countryDataSource.popularCountries;
    self.allCountries = countryDataSource.allCountries;
    
    [self _addConstranit];
}


#pragma mark - UITableViewDatasource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.popularCountries.count;
    }
    
    return self.allCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYCountrySelectorCellIdentifier";
    FLYCountrySelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYCountrySelectorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *countryName;
    NSString *countryCode;
    if (indexPath.section == 0) {
        countryName = [self.popularCountries[indexPath.row] objectForKey:@"name"];
        countryCode = [self.popularCountries[indexPath.row] objectForKey:@"dial_code"];
    } else {
        countryName = [self.allCountries[indexPath.row] objectForKey:@"name"];
        countryCode = [self.allCountries[indexPath.row] objectForKey:@"dial_code"];
    }
    
    [cell configCellWithName:countryName code:countryCode];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor flyColorFlyCountrySelectorBGColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [headerView addSubview:label];
    label.font = [UIFont fontWithName:@"Avenir-Heavy" size:15];
    label.backgroundColor = [UIColor flyColorFlyCountrySelectorBGColor];
    if (section == 0) {
        label.text = @"Popular Countries";
    } else {
        label.text = @"All Countries";
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *countryCode;
    if (indexPath.section == 0) {
        countryCode = [self.popularCountries[indexPath.row] objectForKey:@"dial_code"];
    } else {
        countryCode = [self.allCountries[indexPath.row] objectForKey:@"dial_code"];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)_addConstranit
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.leading.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }];
}

#pragma mark - Navigation bar
- (void)loadLeftBarButton
{
    @weakify(self)
    FLYBlueBackBarButtonItem *barItem = [FLYBlueBackBarButtonItem barButtonItem:YES];
    barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
        @strongify(self)
        [self _backButtonTapped];
    };
    self.navigationItem.leftBarButtonItem = barItem;
}

- (void)_backButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
