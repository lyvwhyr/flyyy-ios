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
#import "FLYMediaService.h"
#import "FLYTopicService.h"

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
    
    if (self.defaultGroup) {
        [self _setDefaultSelectedIndex:self.defaultGroup];
    }
    
    [self updateViewConstraints];
    
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:nil element:nil action:@"impression"];
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
    if ([self.selectedIndex isEqual:indexPath]) {
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
    if ([self.selectedIndex isEqual:indexPath]) {
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
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:@"post" element:@"post_button" action:@"click"];
    
    NSString *defaultStr = LOC(@"FLYPrePostDefaultText");
    if (!self.topicTitle || [self.topicTitle isEqualToString:defaultStr]) {
        [Dialog simpleToast:LOC(@"FLYPrePostDefaultText")];
        return;
    }
    
    BOOL mediaAlreadyUploaded = [FLYAppStateManager sharedInstance].mediaAlreadyUploaded;
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    
    self.postButton.userInteractionEnabled = NO;
    if (mediaAlreadyUploaded) {
        [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
    } else {
        //If media id is still empty at this point, try to upload the media again.
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.delegate = self;
        HUD.textLabel.text = @"Posting...";
        [HUD showInView:self.view];
        
        @weakify(self)
        FLYUploadToS3SuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
            @strongify(self);
            [HUD dismiss];
            [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
        };
        
        FLYUploadToS3ErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            self.postButton.userInteractionEnabled = YES;
            [HUD dismiss];
            [Dialog simpleToast:LOC(@"FLYGenericError")];
        };
        [FLYMediaService getSignedUrlAndUploadWithSuccessBlock:successBlock errorBlock:errorBlock];
    }
}

- (void)_setDefaultSelectedIndex:(FLYGroup *)defaultGroup
{
    NSInteger defaultRow;
    for (int i = 0; i < [self.groups count]; i++) {
        FLYGroup *groupInList = self.groups[i];
        if ([groupInList.groupId isEqualToString:defaultGroup.groupId]) {
            defaultRow = i;
            self.selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
            self.selectedGroup = defaultGroup;
            return;
        }
    }
}

#pragma mark - Service
- (void)_serviceCreateTopicWithParams:(NSDictionary *)dict
{
    NSDictionary *initialParams = @{@"topic_title":self.topicTitle,
                             @"media_id":[FLYAppStateManager sharedInstance].mediaId,
                             @"extension":@"m4a",
                             @"audio_duration":@(self.audioDuration)
                             };
    
    NSMutableDictionary *params = [initialParams mutableCopy];
    if (self.selectedGroup) {
        [params setObject:self.selectedGroup.groupId forKey:@"group_id"];
    }
    
    FLYPostTopicSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        FLYTopic *post = [[FLYTopic alloc] initWithDictory:responseObj];
        NSDictionary *dict = @{kNewPostKey:post};
        [Dialog simpleToast:@"Posted"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewPostReceivedNotification object:self userInfo:dict];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.postButton.userInteractionEnabled = YES;
        
    };
    
    FLYPostTopicErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.postButton.userInteractionEnabled = YES;
        UALog(@"Post error %@", error);
    };
    
    [FLYTopicService postTopic:params successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark - Navigation bar and status barhow
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
}

@end
