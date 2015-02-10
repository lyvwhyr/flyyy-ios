//
//  FLYPrePostViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYPrePostTitleTableViewCell.h"
#import "FLYPrePostChooseGroupTableViewCell.h"
#import "FLYPostButtonView.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "Dialog.h"
#import "FLYRecordViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FLYTopic.h"
#import "FLYGroup.h"
#import "FLYGroupManager.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYPrePostHeaderView.h"

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"
#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 105
#define kLeftPadding    15

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate, FLYPrePostHeaderViewDelegate>

@property (nonatomic) FLYPrePostHeaderView *headerView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) FLYPostButtonView *postButton;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) NSArray *groups;
@property (nonatomic, copy) NSString *topicTitle;

@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) FLYGroup *selectedGroup;

@end

@implementation FLYPrePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    _groups = [NSArray arrayWithArray:[FLYGroupManager sharedInstance].groupList];
    
    self.view.backgroundColor = [UIColor flyBlue];
    
    self.title = @"Post";
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    self.headerView = [FLYPrePostHeaderView new];
    self.headerView.delegate = self;
    [self.view addSubview:self.headerView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[FLYPrePostTitleTableViewCell class] forCellReuseIdentifier:kFlyPrePostTitleCellIdentifier];
    [_tableView registerClass:[FLYPrePostChooseGroupTableViewCell class] forCellReuseIdentifier:kFlyPrePostChooseGroupCellIdentifier];
    
    //Add table background image
     UIImageView *backgroundImageView = [UIImageView new];
     backgroundImageView.image = [UIImage imageNamed:@"icon_record_groups"];
    _tableView.backgroundView = backgroundImageView;
    
    _postButton = [FLYPostButtonView new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_postButtonTapped)];
    [_postButton addGestureRecognizer:tap];
    [self.view addSubview:_postButton];
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)updateViewConstraints
{
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 15);
        make.leading.equalTo(self.view).offset(kLeftPadding);
        make.trailing.equalTo(self.view).offset(-kLeftPadding);
        make.height.equalTo(@150);
    }];
    
    [_postButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(kFlyPostButtonHeight));
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 150);
        make.leading.equalTo(self.view).offset(kLeftPadding);
        make.trailing.equalTo(self.view).offset(-kLeftPadding);
        make.bottom.equalTo(self.view).offset(-kFlyPostButtonHeight);
    }];
    
    if (_overlayView) {
        [_overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kNavBarHeight + kStatusBarHeight + kTitleTextCellHeight);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
    [super updateViewConstraints];
    
}

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
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d%d", kFlyPrePostChooseGroupCellIdentifier, (int)indexPath.section, (int)indexPath.row];
    cell = [[FLYPrePostChooseGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    FLYPrePostChooseGroupTableViewCell *chooseGroupCell = (FLYPrePostChooseGroupTableViewCell *)cell;
    FLYGroup *group = [_groups objectAtIndex:indexPath.row];
    chooseGroupCell.groupName = group.groupName;
    cell = chooseGroupCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    //Set the button state
    if (self.selectedIndex == indexPath) {
        [chooseGroupCell selectCell];
    }
    
    return cell;
}


- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYPrePostChooseGroupTableViewCell *cell = (FLYPrePostChooseGroupTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.selectedIndex.row == indexPath.row && self.selectedIndex.section == indexPath.section) {
        //unselect
        self.selectedIndex = nil;
        self.selectedGroup = nil;
        [cell selectCell];
    } else {
        // deselect previous selected cell
        FLYPrePostChooseGroupTableViewCell *previousSelectedCell = (FLYPrePostChooseGroupTableViewCell *)[tableView cellForRowAtIndexPath:self.selectedIndex];
        [previousSelectedCell selectCell];
        
        // select the cell
        [cell selectCell];
        self.selectedIndex = indexPath;
        self.selectedGroup = [self.groups objectAtIndex:indexPath.row];
    }
}

#pragma mark - FLYPrePostTitleTableViewCellDelegate
- (BOOL)titleTextViewShouldBeginEditing:(UITextView *)textView
{
    [self.view addSubview:self.overlayView];
    [self updateViewConstraints];
    return YES;
}

- (BOOL)titleTextViewShouldEndEditing:(UITextView *)textView
{
    self.topicTitle = textView.text;
    
    [self _exitEditTitleMode];
    return YES;
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [UIView new];
        [_overlayView setBackgroundColor:[UIColor blackColor]];
        _overlayView.alpha = 0.65;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_exitEditTitleMode)];
        [_overlayView addGestureRecognizer:tapGestureRecognizer];
    }
    return _overlayView;
}

- (void)_exitEditTitleMode
{
    _overlayView.alpha = 0;
    [_overlayView removeFromSuperview];
    _overlayView = nil;
    
    FLYPrePostTitleTableViewCell *titleTableCell = (FLYPrePostTitleTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [titleTableCell resignFirstResponder];
}

- (void)_postButtonTapped
{
    if (!self.topicTitle) {
        [Dialog simpleToast:LOC(@"FLYPrePostDefaultText")];
        return;
    }
    
    if (!self.selectedGroup) {
        [Dialog simpleToast:LOC(@"FLYPrePostGroupEmpty")];
        return;
    }
    
    NSString *mediaId = [FLYAppStateManager sharedInstance].mediaId;
    if (mediaId) {
        [self _serviceCreateTopic];
    }
}

//curl -X POST -i -d "topic_title=abc" -d "media_id=418819451816822124" "localhost:3000/v1/topics?token=secret123&media_id=not_valid&group_id=12345&audio_duration=10&extension=m4a"
#pragma mark - Service
- (void)_serviceCreateTopic
{
    NSDictionary *params = @{@"topic_title":self.topicTitle,
                             @"media_id":[FLYAppStateManager sharedInstance].mediaId,
                             @"extension":@"m4a",
                             @"group_id":self.selectedGroup.groupId,
                             @"audio_duration":@10
                             };
    NSString *baseURL = @"topics?token=secret123&&media_id=not_valid&user_id=1349703104000715808";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        FLYTopic *post = [[FLYTopic alloc] initWithDictory:responseObject];
        UALog(@"%@", post);
        [Dialog simpleToast:@"Posted"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UALog(@"Post error %@", error);
    }];
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [FLYUtilities printAutolayoutTrace];
}

@end
