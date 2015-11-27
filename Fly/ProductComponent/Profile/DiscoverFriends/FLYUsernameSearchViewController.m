//
//  FLYUsernameSearchViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 11/26/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYUsernameSearchViewController.h"
#import "FLYFollowUserTableView.h"
#import "FLYProfileViewController.h"
#import "FLYUsersService.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYUser.h"

@interface FLYUsernameSearchViewController () <FLYFollowUserTableViewDelegate>

@property (nonatomic) FLYFollowUserTableView *searchResultTable;

@end

@implementation FLYUsernameSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResultTable = [[FLYFollowUserTableView alloc] initWithType:FLYFollowTypeSearchResult userId:nil];
    self.searchResultTable.delegate = self;
    [self.view addSubview:self.searchResultTable];
}

- (void)updateViewConstraints
{
    [self.searchResultTable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)updateSearchText:(NSString *)searchText
{
    @weakify(self)
    [FLYUsersService autocompleteWithName:searchText successBlock:^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        
        NSArray *rawUsers = [responseObj fly_arrayForKey:@"users"];
        NSMutableArray *users = [NSMutableArray new];
        for (NSDictionary *userDict in rawUsers) {
            FLYUser *user = [[FLYUser alloc] initWithDictionary:userDict];
            [users addObject:user];
        }
        [self.searchResultTable setDatasource:users];
    } errorBlock:^(id responseObj, NSError *error) {
        
    }];
}

#pragma mark - FLYFollowUserTableViewDelegate

- (void)tableCellTapped:(FLYFollowUserTableView *)tableView user:(FLYUser *)user
{
    FLYProfileViewController *profileVC = [[FLYProfileViewController alloc] initWithUserId:user.userId];
    [[self.delegate rootViewController].navigationController pushViewController:profileVC animated:YES];
}

@end
