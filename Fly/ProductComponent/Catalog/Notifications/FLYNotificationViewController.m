
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
#import "SVPullToRefresh.h"
#import "FLYActivityService.h"
#import "UIColor+FLYAddition.h"

@interface FLYNotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UIButton *markAllAsRead;
@property (nonatomic) UITableView *notificationTableView;

@property (nonatomic) NSMutableArray *entries;
@property (nonatomic) FLYActivityService *activityService;

// used for page pagination
@property (nonatomic) NSString *afterTimestamp;

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
    
    self.markAllAsRead = [UIButton buttonWithType:UIButtonTypeCustom];
    self.markAllAsRead.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_clear_all_bg"]];
    [self.markAllAsRead setTitle:LOC(@"FLYMarkAllAsRead") forState:UIControlStateNormal];
    [self.markAllAsRead addTarget:self action:@selector(_markAllAsReadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.markAllAsRead];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.notificationTableView = [UITableView new];
    self.notificationTableView.scrollsToTop = YES;
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    self.notificationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.notificationTableView];
    [self _addViewConstraints];
    
    [self _initService];
}

- (void)_initService
{
    self.activityService = [FLYActivityService new];
    [self _load:YES after:nil];
    @weakify(self)
    [self.notificationTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO after:self.afterTimestamp];
    }];
}

- (void)_load:(BOOL)first after:(NSString *)after
{
    @weakify(self)
    FLYActivityGetSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.notificationTableView.infiniteScrollingView stopAnimating];
        NSDictionary *results = responseObj;
        NSArray *activitiesArray = [results objectForKey:@"activities"];
        self.state = FLYViewControllerStateReady;
        if (first) {
            [self.entries removeAllObjects];
        }
        for(int i = 0; i < activitiesArray.count; i++) {
            FLYNotification *notification = [[FLYNotification alloc] initWithDictionary:activitiesArray[i]];
            [self.entries addObject:notification];
        }
        
        [self.notificationTableView reloadData];
    };
    FLYActivityGetErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        [self.notificationTableView.infiniteScrollingView stopAnimating];
    };
    [self.activityService nextPageWithBefore:nil after:after firstPage:first successBlock:successBlock errorBlock:errorBlock];
}

- (void)_addViewConstraints
{
    [self.markAllAsRead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(11);
        make.leading.equalTo(self.view);
        make.height.equalTo(@(37));
        make.trailing.equalTo(self.view);
    }];
    
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight;
    [self.notificationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.markAllAsRead.mas_bottom);
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
        FLYNotification *notification = self.entries[indexPath.row];
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
    FLYNotification *notification = self.entries[indexPath.row];
    return [FLYNotificationTableViewCell heightForNotification:notification];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}

- (void)_markAllAsReadTapped
{
    
}

@end
