
//
//  FLYNotificationViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYNotificationViewController.h"
#import "FLYNotificationTableViewCell.h"
#import "FLYNotification.h"

@interface FLYNotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *notificationTableView;

@property (nonatomic) NSMutableArray *entries;

@end

@implementation FLYNotificationViewController


- (instancetype)init
{
    if (self = [super init]) {
        _entries = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.notificationTableView = [UITableView new];
    self.notificationTableView.scrollsToTop = YES;
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    self.notificationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.notificationTableView];
    [self _addViewConstraints];
}

- (void)_addViewConstraints
{
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight;
    [self.notificationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(tableViewHeight));
    }];
}


# pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYNotificationTableViewCellCellIdentifier";
    FLYNotificationTableViewCell *cell = [self.notificationTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FLYNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        FLYNotification *notification = self.entries[indexPath.row - 1];
        FLYNotification *notification = [FLYNotification new];
        [cell setupCell:notification];
    }
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYNotification *notification = [FLYNotification new];
//    FLYNotificationTableViewCell *cell = (FLYNotificationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [FLYNotificationTableViewCell heightForNotification:notification];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    //return [self.entries count];
}



@end
