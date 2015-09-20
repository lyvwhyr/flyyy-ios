//
//  FLYTagSearchViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 8/23/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagSearchViewController.h"
#import "FLYGroup.h"
#import "FLYTagListCell.h"
#import "FLYTagsService.h"
#import "FLYAppStateManager.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYGroupViewController.h"

@interface FLYTagSearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *searchResultTable;
@property (nonatomic ,copy) NSString *searchString;

@property (nonatomic) NSMutableArray *tags;
@property (nonatomic) FLYTagsService *tagsService;
@property (nonatomic) NSString *cursor;

@end

@implementation FLYTagSearchViewController

- (instancetype)initWithSearchType:(FLYTagListType)type;

{
    if (self = [super init]) {
        _tags = [NSMutableArray new];
        _tagListType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResultTable = [UITableView new];
    self.searchResultTable.dataSource = self;
    self.searchResultTable.delegate = self;
    self.searchResultTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchResultTable.translatesAutoresizingMaskIntoConstraints = NO;
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

#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYTagListCell *cell;
    static NSString *cellIdentifier = @"FLYTagSearchCell";
    cell = (FLYTagListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYTagListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    FLYGroup *tag = [self.tags objectAtIndex:(indexPath.row)];
    cell.groupName = tag.groupName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = ((FLYGroup *)[self.tags objectAtIndex:indexPath.row]).groupName;
    [[FLYScribe sharedInstance] logEvent:@"group_list" section:groupName  component:nil element:nil action:@"click"];
    FLYGroup *group = self.tags[indexPath.row];
    FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:group];
    FLYTagListBaseViewController *parentVC = (FLYTagListBaseViewController *)self.parentViewController;
    [[parentVC.delegate rootViewController].navigationController pushViewController:vc animated:YES];
}


#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)updateSearchText:(NSString *)searchText
{
    if (self.tagListType == FLYTagListTypeMine) {
        NSMutableArray *rawTags = [NSMutableArray arrayWithArray:[FLYAppStateManager sharedInstance].currentUser.tags];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"description beginswith[cd] %@", searchText];
        self.tags = [[rawTags filteredArrayUsingPredicate:predicate] copy];
        [self.searchResultTable reloadData];
    } else {
        @weakify(self)
        [FLYTagsService autocompleteWithName:searchText successBlock:^(AFHTTPRequestOperation *operation, id responseObj) {
            @strongify(self)
            [self.tags removeAllObjects];
            NSArray *rawTags = [responseObj fly_arrayForKey:@"tags"];
            for (NSDictionary *tagDict in rawTags) {
                FLYGroup *tag = [[FLYGroup alloc] initWithDictory:tagDict];
                [self.tags addObject:tag];
            }
            [self.searchResultTable reloadData];
        } errorBlock:^(id responseObj, NSError *error) {
            
        }];
    }
}

- (void)_populateTags:(FLYTagListType)type
{
    if (type == FLYTagListTypeMine) {
        self.tags = [NSMutableArray arrayWithArray:[FLYAppStateManager sharedInstance].currentUser.tags];
    }
}


@end
