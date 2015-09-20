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
    }
}

- (void)_populateTags:(FLYTagListType)type
{
    if (type == FLYTagListTypeMine) {
        self.tags = [NSMutableArray arrayWithArray:[FLYAppStateManager sharedInstance].currentUser.tags];
    } else {
        
    }
}


@end
