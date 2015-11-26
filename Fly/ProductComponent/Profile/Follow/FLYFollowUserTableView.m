//
//  FLYFollowUserTableView.m
//  Flyy
//
//  Created by Xingxing Xu on 11/15/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFollowUserTableView.h"
#import "SVPullToRefresh.h"
#import "FLYFollowUserTableViewCell.h"
#import "FLYUsersService.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"

@interface FLYFollowUserTableView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) FLYFollowType type;
@property (nonatomic) NSString *userId;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableArray *entries;
@property (nonatomic) NSString *cursor;

@end

@implementation FLYFollowUserTableView

- (instancetype)initWithType:(FLYFollowType)type userId:(NSString *)userId
{
    if (self = [super init]) {
        _type =type;
        _userId = userId;
        _entries = [NSMutableArray new];
        
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_tableView];
        
        [self _initService];
    }
    return self;
}

- (void)_initService
{
    @weakify(self)
    [_tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self _load:NO cursor:self.cursor];
    }];
    [self _load:YES cursor:nil];
}

- (void)_load:(BOOL)first cursor:(NSString *)cursor
{
    @weakify(self)
    FLYGetFollowerListSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        [self.tableView.infiniteScrollingView stopAnimating];
        if (!responseObj) {
            return;
        }
        NSArray *usersArr = [responseObj fly_arrayForKey:@"users"];
        self.cursor = [responseObj fly_stringForKey:@"cursor"];
        for (int i = 0; i < usersArr.count; i++) {
            NSDictionary *dict = usersArr[i];
            FLYUser *user = [[FLYUser alloc] initWithDictionary:dict];
            if ([self _isUserInArray:user]) {
                continue;
            }
            [self.entries addObject:user];
        }
        [self.tableView reloadData];
        [self updateConstraints];
    };
    
    FLYGetFollowerListErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error){
        [self.tableView.infiniteScrollingView stopAnimating];
    };
    
    switch (self.type) {
        case FLYFollowTypeFollowing: {
            [FLYUsersService getFollowingWithUserId:self.userId firstPage:first cursor:cursor successBlock:successBlock errorBlock:errorBlock];
            break;
        }
        case FLYFollowTypeFollower: {
            [FLYUsersService getFollowersWithUserId:self.userId firstPage:first cursor:cursor successBlock:successBlock errorBlock:errorBlock];
            break;
        }
        
        case FLYFollowTypeLeadboard: {
            [FLYUsersService getLeaderboardFirstPage:first cursor:cursor successBlock:successBlock errorBlock:errorBlock];
            break;
        }
            
        default:
            break;
    }
}

- (void)updateConstraints
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [super updateConstraints];
}


#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYEverythingElseCell";
    FLYFollowUserTableViewCell *cell = [[FLYFollowUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setupCellWithUser:(FLYUser *)self.entries[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYUser *user = self.entries[indexPath.row];
    [self.delegate tableCellTapped:self user:user];
}

- (BOOL)_isUserInArray:(FLYUser *)user
{
    if ([self.entries count] == 0) {
        return NO;
    }
    for (int i = 0; i < self.entries.count; i++) {
        FLYUser *userInArray = self.entries[i];
        if ([user.userId isEqual:userInArray.userId]) {
            return YES;
        }
    }
    return NO;
}


@end
