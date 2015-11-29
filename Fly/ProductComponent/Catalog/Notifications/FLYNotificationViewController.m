
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
#import "FLYTopicDetailViewController.h"
#import "Dialog.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYIconButton.h"
#import "UIFont+FLYAddition.h"
#import "FLYUser.h"

@interface FLYNotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UIButton *markAllReadContainerView;
@property (nonatomic) FLYIconButton *markAllAsRead;

@property (nonatomic) UITableView *notificationTableView;

@property (nonatomic) NSMutableArray *entries;
@property (nonatomic) FLYActivityService *activityService;

// used for page pagination
@property (nonatomic) NSString *afterTimestamp;
@property (nonatomic) NSString *cursor;

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
    self.view.backgroundColor = [UIColor flySettingBackgroundColor];
    
    self.markAllReadContainerView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.markAllReadContainerView.backgroundColor = [UIColor colorWithRed:68.0/255 green:209.0/255 blue:79.0/255 alpha:0.73];    [self.markAllReadContainerView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.markAllReadContainerView addTarget:self action:@selector(_markAllAsReadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.markAllReadContainerView];
    
    self.markAllAsRead = [[FLYIconButton alloc] initWithText:LOC(@"FLYMarkAllAsRead") textFont:[UIFont flyFontWithSize:15] textColor:[UIColor whiteColor] icon:@"icon_checkmark" isIconLeft:NO];
    [self.markAllAsRead addTarget:self action:@selector(_markAllAsReadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.markAllAsRead];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.notificationTableView = [UITableView new];
    self.notificationTableView.backgroundColor = [UIColor flySettingBackgroundColor];
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
    [self _load:YES];
    @weakify(self)
    [self.notificationTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO];
    }];
}

- (void)_load:(BOOL)first
{
    @weakify(self)
    FLYActivityGetSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.notificationTableView.infiniteScrollingView stopAnimating];
        NSDictionary *results = responseObj;
        NSArray *activitiesArray = [results objectForKey:@"activities"];
        if ([activitiesArray count] == 0) {
            return;
        }
        self.cursor = [responseObj fly_stringForKey:@"cursor"];
        if (!self.cursor || [self.cursor isEqualToString:@""]) {
            self.cursor = nil;
        }
        
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
    [self.activityService nextPageWithCursor:self.cursor firstPage:first successBlock:successBlock errorBlock:errorBlock];
}

- (void)_addViewConstraints
{
    [self.markAllReadContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(5);
        make.leading.equalTo(self.view);
        make.height.equalTo(@(37));
        make.trailing.equalTo(self.view);
    }];
    
    [self.markAllAsRead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.markAllReadContainerView);
        make.centerY.equalTo(self.markAllReadContainerView);
    }];
    
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight - 37;
    [self.notificationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.markAllReadContainerView.mas_bottom);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(tableViewHeight));
    }];
}


# pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYNotification *notification = self.entries[indexPath.row];
    
    static NSString *cellIdentifier = @"FLYNotificationTableViewCellCellIdentifier";
    FLYNotificationTableViewCell *cell = [self.notificationTableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell) {
        cell = [[FLYNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    [cell setupCell:notification];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYNotification *notificaiton = (FLYNotification *)self.entries[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    FLYNotificationTableViewCell *cell = (FLYNotificationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell clearReadState];
    
    if ([notificaiton.action isEqualToString:@"followed"]) {
        FLYNotification *notif = self.entries[indexPath.row];
        FLYUser *actor = [[FLYUser alloc] initWithDictionary:notif.actors[0]];
        [self.delegate visitProfile:actor];
    } else {
        FLYTopic *topic = notificaiton.topic;
        [self.delegate visitTopicDetail:topic];
    }
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
    if (![FLYAppStateManager sharedInstance].currentUser) {
        [Dialog simpleToast:LOC(@"FLYNeedLogin")];
        return;
    }
    
    @weakify(self)
    [FLYActivityService markAllRead:^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [FLYAppStateManager sharedInstance].unreadActivityCount = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kActivityCountUpdatedNotification object:self];
        
        for (int i = 0; i < self.entries.count; i++) {
            FLYNotification *notification = self.entries[i];
            notification.isRead = YES;
        }
        [self.notificationTableView reloadData];
        
        [Dialog simpleToast:LOC(@"FLYAllNotificationsRead")];
        
    } errorBlock:^(id responseObj, NSError *error) {
        UALog(@"Mark all read API failed");
    }];
}

@end
