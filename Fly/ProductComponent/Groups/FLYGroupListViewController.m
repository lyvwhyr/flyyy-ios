//
//  FLYGroupsViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupListViewController.h"
#import "FLYGroupListTableViewCell.h"

@interface FLYGroupListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *groupsTabelView;

@property (nonatomic) NSMutableArray *groups;



@end

@implementation FLYGroupListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_groupsTabelView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:[self.view constraints]];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.parentViewController.view);
        make.leading.equalTo(self.parentViewController.view);
        make.width.equalTo(@(CGRectGetWidth(self.parentViewController.view.bounds)));
        make.height.equalTo(@(CGRectGetHeight(self.parentViewController.view.bounds) - kTabBarViewHeight));
    }];
    
    [_groupsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYGroupsViewControllerTableCellIdentifier";
    FLYGroupListTableViewCell *cell = (FLYGroupListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYGroupListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.groupName = [_groups objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYGroupListTableViewCell *cell = (FLYGroupListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

@end
