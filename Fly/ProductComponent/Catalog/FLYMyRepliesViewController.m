//
//  FLYMyRepliesViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 4/3/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYMyRepliesViewController.h"
#import "FLYNavigationBar.h"
#import "FLYNavigationController.h"
#import "UIColor+FLYAddition.h"
#import "FLYReplyService.h"
#import "SVPullToRefresh.h"
#import "FLYReply.h"
#import "FLYTopic.h"
#import "FLYMyRepliesCell.h"
#import "FLYTopicDetailViewController.h"

@interface FLYMyRepliesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *repliesTableView;

@property (nonatomic) NSMutableArray *entries;

// used for reply pagination
@property (nonatomic) NSString *beforeTimestamp;

// services
@property (nonatomic) FLYReplyService *replyService;

@end

@implementation FLYMyRepliesViewController

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
    self.title = LOC(@"FLYEverythingElseMyReplies");
    
    self.repliesTableView = [UITableView new];
    self.repliesTableView.delegate = self;
    self.repliesTableView.dataSource = self;
    self.repliesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.repliesTableView];
    
    [self _addViewConstraints];
    
    [self _initService];
}

- (void)_addViewConstraints
{
    CGFloat tableViewHeight = CGRectGetHeight(self.view.bounds) - kStatusBarHeight - kNavBarHeight;
    [self.repliesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(tableViewHeight));
    }];
}


#pragma mark - UITableViewDelegate, datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d_%d", @"FLYMyRepliesCellIdentifier", (int)indexPath.section, (int)indexPath.row];
    FLYMyRepliesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYMyRepliesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLYTopic *topic = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"topic"];
    FLYReply *reply = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"reply"];
    [cell setupCellWithTopic:topic reply:reply];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraints];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FLYTopic *topic = [[self.entries objectAtIndex:indexPath.row] objectForKey:@"topic"];
    FLYTopicDetailViewController *viewController = [[FLYTopicDetailViewController alloc] initWithTopic:topic];
    viewController.isBackFullScreen = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - services
- (void)_initService
{
    self.replyService = [FLYReplyService getMyReplies];
    [self _load:YES before:nil];
    @weakify(self)
    [self.repliesTableView addPullToRefreshWithActionHandler:^{
        @strongify(self)
        [self _load:YES before:nil];
    }];
    
    
    [self.repliesTableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO before:self.beforeTimestamp];
    }];
}

- (void)_load:(BOOL)first before:(NSString *)before
{
    @weakify(self)
    FLYGetMyRepliesSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.repliesTableView.pullToRefreshView stopAnimating];
        [self.repliesTableView.infiniteScrollingView stopAnimating];

        NSArray *repliesArray = responseObj;
        
        self.state = FLYViewControllerStateReady;
        if (first) {
            [self.entries removeAllObjects];
        }
        
        for(int i = 0; i < repliesArray.count; i++) {
            FLYReply *reply = [[FLYReply alloc] initWithDictionary:repliesArray[i]];
            FLYTopic *topic = [[FLYTopic alloc] initWithDictory:[repliesArray[i] objectForKey:@"topic"]];
            NSDictionary *dict = @{@"topic":topic, @"reply":reply};
            [self.entries addObject:dict];
        }
        //Set up before id for load more
        NSDictionary *lastEntry = [self.entries lastObject];
        self.beforeTimestamp = ((FLYReply *)[lastEntry objectForKey:@"reply"]).createdAt;
        [self.repliesTableView reloadData];
    };
    FLYGetMyRepliesErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        @strongify(self)
        [self.repliesTableView.pullToRefreshView stopAnimating];
        [self.repliesTableView.infiniteScrollingView stopAnimating];
    };
    [self.replyService nextPage:before firstPage:first successBlock:successBlock errorBlock:errorBlock];
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
