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

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"
#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 70

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate, FLYPrePostTitleTableViewCellDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) FLYPostButtonView *postButton;
@property (nonatomic) UIView *overlayView;

@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic) NSMutableArray *groups;

@end

@implementation FLYPrePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _groups = [NSMutableArray new];
    
    [self _addTestData];
    
    self.view.backgroundColor = [UIColor flyFeedGrey];
    
    self.title = @"Post";
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[FLYPrePostTitleTableViewCell class] forCellReuseIdentifier:kFlyPrePostTitleCellIdentifier];
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

- (void)updateViewConstraints
{
    [_postButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(kFlyPostButtonHeight));
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return _groups.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0 && indexPath.section == 0) {
        static NSString *cellIdentifier = kFlyPrePostTitleCellIdentifier;
        cell = (UITableViewCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[FLYPrePostTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        ((FLYPrePostTitleTableViewCell *)cell).delegate = self;
    } else {
        static NSString *cellIdentifier = kFlyPrePostChooseGroupCellIdentifier;
        FLYPrePostChooseGroupTableViewCell *chooseGroupCell;
        chooseGroupCell = [[FLYPrePostChooseGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        chooseGroupCell.groupName = [_groups objectAtIndex:indexPath.row];
        cell = chooseGroupCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        return kTitleTextCellHeight;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FLYPrePostChooseGroupTableViewCell class]]) {
        [((FLYPrePostChooseGroupTableViewCell *)cell) selectCell];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor tableHeaderGrey];
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
    sectionHeader.textColor = [UIColor tableHeaderTextGrey];
    sectionHeader.text = @"     Add a Group";
    if (section == 1) {
        return sectionHeader;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 40;
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

- (void)_addTestData
{
    [_groups addObject:@"Drugs and alcohol"];
    [_groups addObject:@"Rape"];
    [_groups addObject:@"Love confession"];
    [_groups addObject:@"LGBTQ"];
    [_groups addObject:@"Relationships"];
    
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
    [_groups addObject:@"Tattoosand piercings"];
    [_groups addObject:@"Travel"];
    [_groups addObject:@"Money"];
    [_groups addObject:@"Faith"];
    [_groups addObject:@"Family"];
}

- (void)_postButtonTapped
{
    NSString *mediaId = [FLYAppStateManager sharedInstance].mediaId;
    if (mediaId) {
        [self _serviceCreateTopic];
    }
}

//curl -X POST -i -d "topic_title=abc" -d "media_id=418819451816822124" "localhost:3000/v1/topics?token=secret123&media_id=not_valid&group_id=12345&audio_duration=10&extension=m4a"
#pragma mark - Service
- (void)_serviceCreateTopic
{
    //TODO:use real data
    NSNumber *mediaIdNum = [NSNumber numberWithLongLong:[[FLYAppStateManager sharedInstance].mediaId longLongValue]];
    NSDictionary *params = @{@"topic_title":self.topicTitle,
                             @"media_id":mediaIdNum,
                             @"extension":@"m4a",
                             @"group_id":@"11245832070063228345",
                             @"audio_duration":@10
                             };
    NSString *baseURL = @"http://localhost:3000/v1/topics?token=secret123&&media_id=not_valid&user_id=1349703104000715808";
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

@end
