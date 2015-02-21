//
//  FLYPrePostViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYPrePostChooseGroupTableViewCell.h"
#import "FLYPostButtonView.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "JGProgressHUDIndicatorView.h"
#import "JGProgressHUDRingIndicatorView.h"
#import "Dialog.h"
#import "FLYRecordViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FLYTopic.h"
#import "FLYGroup.h"
#import "FLYGroupManager.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYPrePostHeaderView.h"
#import "FLYFeedViewController.h"
#import "FLYEndpointRequest.h"
#import "FLYUser.h"
#import "FLYAudioStateManager.h"

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"

#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 105
#define kLeftPadding    15

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate, FLYPrePostHeaderViewDelegate, JGProgressHUDDelegate>

@property (nonatomic) FLYPrePostHeaderView *headerView;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) FLYPostButtonView *postButton;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) NSArray *groups;
@property (nonatomic, copy) NSString *topicTitle;

@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) FLYGroup *selectedGroup;

@property (nonatomic, copy) mediaUploadSuccessBlock successBlock;
@property (nonatomic, copy) mediaUploadFailureBlock failureBlock;


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
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[FLYPrePostChooseGroupTableViewCell class] forCellReuseIdentifier:kFlyPrePostChooseGroupCellIdentifier];
    
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

- (void)dealloc
{
    
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
    if (self.selectedIndex == indexPath) {
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
    
    [self.headerView resignFirstResponder];
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
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    if (mediaId) {
        [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
    } else {
        //If media id is still empty at this point, try to upload the media again.
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.delegate = self;
        HUD.textLabel.text = @"Posting...";
        [HUD showInView:self.view];
        
        @weakify(self)
        [FLYEndpointRequest uploadAudioFileServiceWithUserId:userId successBlock:^(NSString *mediaId) {
            @strongify(self);
            [HUD dismiss];
            [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
        } failureBlock:^{
            [HUD dismiss];
            [Dialog simpleToast:LOC(@"FLYGenericError")];
        }];
    }
}

//curl -X POST -i -d "topic_title=abc" -d "media_id=418819451816822124" "localhost:3000/v1/topics?token=secret123&media_id=not_valid&group_id=12345&audio_duration=10&extension=m4a"
#pragma mark - Service
- (void)_serviceCreateTopicWithParams:(NSDictionary *)dict
{
    NSString *userId = [dict objectForKey:@"user_id"];
    NSDictionary *params = @{@"topic_title":self.topicTitle,
                             @"media_id":[FLYAppStateManager sharedInstance].mediaId,
                             @"extension":@"m4a",
                             @"group_id":self.selectedGroup.groupId,
                             @"audio_duration":@(self.audioDuration)
                             };
    NSString *baseURL =  [NSString stringWithFormat:@"topics?token=secret123&&media_id=not_valid&user_id=%@", userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:baseURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        FLYTopic *post = [[FLYTopic alloc] initWithDictory:responseObject];
        NSDictionary *dict = @{kNewPostKey:post};
        [Dialog simpleToast:@"Posted"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewPostReceivedNotification object:self userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUsePlaybackOnlyNotification object:self];
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
