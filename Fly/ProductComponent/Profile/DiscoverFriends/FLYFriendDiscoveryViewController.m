//
//  FLYFriendDiscoveryViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 11/22/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFriendDiscoveryViewController.h"
#import "FLYSearchBar.h"
#import "FLYShareFriendTableViewCell.h"
#import "FLYFollowUserTableView.h"
#import "FLYProfileViewController.h"
#import "FLYUser.h"
#import "FLYUsernameSearchViewController.h"

typedef NS_ENUM(NSInteger, FLYShareType) {
    FLYShareTypeInviteContracts = 0,
    FLYShareTypeFacebook,
    FLYShareTypeOther,
    FLYShareTypeNumber
};

@interface FLYFriendDiscoveryViewController () <FLYSearchBarDelegate, UITableViewDataSource, UITableViewDelegate, FLYFollowUserTableViewDelegate, FLYUsernameSearchViewControllerDelegate>

@property (nonatomic) FLYSearchBar *searchBar;
@property (nonatomic) UITableView *shareTableView;
@property (nonatomic) UILabel *popularUsersLabel;
@property (nonatomic) FLYFollowUserTableView *popularUsersTable;

@property (nonatomic) FLYUsernameSearchViewController *searchVC;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation FLYFriendDiscoveryViewController

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:@"UIKeyboardWillShowNotification"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Discover Friends";
    self.view.backgroundColor = [UIColor tableHeaderGrey];
    
    self.searchBar = [FLYSearchBar new];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    self.shareTableView = [UITableView new];
    self.shareTableView.dataSource = self;
    self.shareTableView.delegate = self;
    [self.view addSubview:self.shareTableView];
    
    self.popularUsersLabel = [UILabel new];
    self.popularUsersLabel.text = LOC(@"FLYPopularUsersLabelText");
    self.popularUsersLabel.font = [UIFont fontWithName:@"Futura-Medium" size:14];
    self.popularUsersLabel.textColor = [FLYUtilities colorWithHexString:@"#9C9C9C"];
    [self.popularUsersLabel sizeToFit];
    [self.view addSubview:self.popularUsersLabel];
    
    self.popularUsersTable = [[FLYFollowUserTableView alloc] initWithType:FLYFollowTypeLeadboard userId:nil];
    self.popularUsersTable.delegate = self;
    [self.view addSubview:self.popularUsersTable];
    
    [self updateViewConstraints];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return FLYShareTypeNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYShareFriendTableViewCell";
    FLYShareFriendTableViewCell *cell = [[FLYShareFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == FLYShareTypeInviteContracts) {
        [cell configCellWithImage:@"icon_invite_contact" text:LOC(@"FLYShareTypeInviteContacts")];
    } else if (indexPath.row == FLYShareTypeFacebook) {
        [cell configCellWithImage:@"icon_invite_facebook" text:LOC(@"FLYShareTypeFacebook")];
    } else {
        [cell configCellWithImage:@"icon_invite_other" text:LOC(@"FLYShareTypeOther")];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

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

-(void)updateViewConstraints
{
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 8);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(31));
    }];
    
    [self.shareTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(8);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(180));
    }];
    
    [self.popularUsersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shareTableView.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(23);
    }];
    
    [self.popularUsersTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.popularUsersLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    if (self.searchVC) {
        [self.searchVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).offset(3);
            make.leading.mas_equalTo(self.view);
            make.width.mas_equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-self.keyboardHeight + 44);
        }];
        
    }
    
    [super updateViewConstraints];
}

#pragma mark - FLYSearchBarDelegate

- (void)searchBarDidBeginEditing:(FLYSearchBar *)searchBar
{
    [self _setNoneSearchViewsVisible:NO];
}

- (void)searchBarCancelButtonClicked:(FLYSearchBar *)searchBar
{
    [self _setNoneSearchViewsVisible:YES];
    
    [self.searchVC.view removeFromSuperview];
    self.searchVC = nil;
}

- (void)searchBar:(FLYSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self _setNoneSearchViewsVisible:NO];
    
    if (searchText.length < 1) {
        self.searchVC.view.hidden = YES;
    } else {
        self.searchVC.view.hidden = NO;
        
        if (!self.searchVC) {
            self.searchVC = [FLYUsernameSearchViewController new];
            self.searchVC.delegate = self;
            [self.searchVC.view removeFromSuperview];
            [self.view addSubview:self.searchVC.view];
            [self addChildViewController:self.searchVC];
            [self updateViewConstraints];
        }
        [self.searchVC updateSearchText:searchText];
    }
}

- (void)_setNoneSearchViewsVisible:(BOOL)visible
{
    self.shareTableView.hidden = !visible;
    self.popularUsersLabel.hidden = !visible;
    self.popularUsersTable.hidden = !visible;
}

#pragma mark - FLYFollowUserTableViewDelegate

- (void)tableCellTapped:(FLYFollowUserTableView *)tableView user:(FLYUser *)user
{
    FLYProfileViewController *profileVC = [[FLYProfileViewController alloc] initWithUserId:user.userId];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - FLYUsernameSearchViewControllerDelegate
- (UIViewController *)rootViewController
{
    return self;
}

- (BOOL)isFullScreen
{
    return YES;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardHeight = kbSize.height;
    [self updateViewConstraints];
}

@end
