//
//  FLYTagListBaseViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 9/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListBaseViewController.h"
#import "FLYTagListGlobalViewController.h"
#import "FLYTagListTableViewCell.h"
#import "FLYTagListSuggestTableViewCell.h"
#import "SCLAlertView.h"
#import "UIColor+FLYAddition.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYMainViewController.h"
#import "FLYFeedViewController.h"
#import "FLYGroupViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYTagListCell.h"
#import "FLYGroupManager.h"
#import "FLYGroup.h"
#import "Dialog.h"
#import "PPiFlatSegmentedControl.h"
#import "UIFont+FLYAddition.h"
#import "FLYSearchBar.h"
#import "FLYTagListViewController.h"
#import "FLYHintView.h"
#import "FLYUser.h"


#define kSuggestGroupRow 0

@interface FLYTagListBaseViewController () <UITableViewDataSource, UITableViewDelegate, FLYSearchBarDelegate>

@property (nonatomic) PPiFlatSegmentedControl *segmentedControl;
@property (nonatomic) FLYSearchBar *searchBar;
@property (nonatomic) BOOL searching;
@property (nonatomic) FLYHintView *hintView;
@property (nonatomic) UITableView *groupsTabelView;

@property (nonatomic) NSMutableArray *groups;
@property (nonatomic) FLYTagListType tagListType;

@end

@implementation FLYTagListBaseViewController

- (instancetype)initWithTagListType:(FLYTagListType)type
{
    if (self = [super init]) {
        _tagListType = type;
        [self populateTags:_tagListType];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tagsUpdated) name:kNotificationMyTagsUpdated object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)populateTags:(FLYTagListType)type
{
    if (type == FLYTagListTypeMine) {
        _groups = [NSMutableArray arrayWithArray:[FLYAppStateManager sharedInstance].currentUser.tags];
    } else {
        _groups = [NSMutableArray new];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOC(@"FLYTags");
    
    // search bar
    self.searchBar = [FLYSearchBar new];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    self.groupsTabelView = [UITableView new];
    self.groupsTabelView.translatesAutoresizingMaskIntoConstraints = NO;
    self.groupsTabelView.backgroundColor = [UIColor clearColor];
    self.groupsTabelView.delegate = self;
    self.groupsTabelView.dataSource = self;
    self.groupsTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.groupsTabelView];
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = LOC(@"FLYTags");
    [titleLabel sizeToFit];
    self.parentViewController.navigationItem.titleView = titleLabel;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title = LOC(@"FLYTags");
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)updateViewConstraints
{
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 8);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(31));
    }];
    
    [_groupsTabelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(3);
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(self.view);
    }];
    
    if (_hintView && _hintView.hidden == NO) {
        [_hintView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.view);
            make.trailing.mas_equalTo(self.view);
            make.top.equalTo(self.searchBar.mas_bottom).offset(40);
        }];
    }
    
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
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d%d", @"identifier", (int)indexPath.section, (int)indexPath.row];
    cell = [[FLYTagListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    FLYTagListCell *chooseGroupCell = (FLYTagListCell *)cell;
    FLYGroup *group = [_groups objectAtIndex:(indexPath.row)];
    chooseGroupCell.groupName = group.groupName;
    cell = chooseGroupCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupName = ((FLYGroup *)[self.groups objectAtIndex:indexPath.row]).groupName;
    [[FLYScribe sharedInstance] logEvent:@"group_list" section:groupName  component:nil element:nil action:@"click"];
    FLYGroup *group = self.groups[indexPath.row];
    FLYGroupViewController *vc = [[FLYGroupViewController alloc] initWithGroup:group];
    [[self.delegate rootViewController].navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

#pragma mark - FLYSearchBarDelegate
- (void)searchBarDidBeginEditing:(FLYSearchBar *)searchBar
{
    [self hintView];
    self.groupsTabelView.hidden = YES;
    self.hintView.hidden = NO;
    [self updateViewConstraints];
}

- (void)searchBarCancelButtonClicked:(FLYSearchBar *)searchBar
{
    self.hintView.hidden = YES;
    self.groupsTabelView.hidden = NO;
}

- (void)searchBar:(FLYSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length <= 2) {
        self.groupsTabelView.hidden = YES;
        self.hintView.hidden = NO;
    } else {
        self.hintView.hidden = YES;
    }
}

- (FLYHintView *)hintView
{
    if (!_hintView) {
        _hintView = [[FLYHintView alloc] initWithText:LOC(@"FLYTagListSearchAtLeastTwoChars") image:nil];
        _hintView.translatesAutoresizingMaskIntoConstraints = NO;
        _hintView.hidden = YES;
        [self.view addSubview:_hintView];
    }
    return _hintView;
}

- (void)_tagsUpdated
{
    self.groups = [FLYAppStateManager sharedInstance].currentUser.tags;
    [self.groupsTabelView reloadData];
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
