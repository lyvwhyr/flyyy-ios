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
#import "FLYPushNotificationManager.h"
#import "UIFont+FLYAddition.h"

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"

#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 105
#define kLeftPadding    15
#define kTagButtonHorizontalSpacing 19
#define kTagButtonVerticalSpacing 12

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate, FLYPrePostHeaderViewDelegate, JGProgressHUDDelegate>

@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) FLYPrePostHeaderView *headerView;
@property (nonatomic) FLYPostButtonView *postButton;
@property (nonatomic) UIView *overlayView;

@property (nonatomic) NSArray *groups;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic) NSMutableArray *tagButtonArray;
@property (nonatomic) CGRect lastTagFrame;
@property (nonatomic) BOOL alreadyLayouted;

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
    
    self.title = @"Post";
    
    self.backgroundImageView = [UIImageView new];
    self.backgroundImageView.image = [UIImage imageNamed:@"bg_post_tag"];
    [self.view addSubview:self.backgroundImageView];
    
    self.headerView = [FLYPrePostHeaderView new];
    self.headerView.delegate = self;
    [self.view addSubview:self.headerView];
    
    _postButton = [FLYPostButtonView new];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_postButtonTapped)];
    [_postButton addGestureRecognizer:tap];
    [self.view addSubview:_postButton];
    
    // Initialize tags
    _tagButtonArray = [NSMutableArray new];
    [self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FLYGroup *group = (FLYGroup *)obj;
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tagButton.layer.cornerRadius = 4.0f;
        tagButton.layer.borderColor = [UIColor flyShareTextGrey].CGColor;
        tagButton.layer.borderWidth = 1.0f;
        tagButton.tag = idx;
        tagButton.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
        tagButton.titleLabel.font = [UIFont flyFontWithSize:14.0f];
        [tagButton setTitleColor:[FLYUtilities colorWithHexString:@"#737373"] forState:UIControlStateNormal];
        [tagButton addTarget:self action:@selector(_tagSelected:) forControlEvents:UIControlEventTouchUpInside];
        [tagButton setTitle:group.groupName forState:UIControlStateNormal];
        [tagButton sizeToFit];
        [self.view addSubview:tagButton];
        [self.tagButtonArray addObject:tagButton];
    }];
    
    // post from tag page
    if (self.defaultGroup) {
        [self _setDefaultSelectedIndex:self.defaultGroup];
    }
    
    [self updateViewConstraints];
    
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:nil element:nil action:@"impression"];
}

- (void)_tagSelected:(UIButton *)target
{
    UALog(@"hello");
}

- (void)updateViewConstraints
{
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 15);
        make.leading.equalTo(self.view).offset(kLeftPadding);
        make.trailing.equalTo(self.view).offset(-kLeftPadding);
        make.height.equalTo(@150);
    }];
    
    // tag buttons
    UIButton *previousButton;
    CGFloat currentWidth = 0.0;
    CGFloat MAX_ROW_WIDTH = CGRectGetWidth(self.view.bounds) - 2 * kLeftPadding;
    NSMutableArray *buttonsInRow = [NSMutableArray new];
    for (UIButton *currentButton in self.tagButtonArray) {
        CGFloat buttonWidth = CGRectGetWidth(currentButton.bounds);
        if ((buttonWidth + currentWidth) < MAX_ROW_WIDTH) {
            if (previousButton == nil) {
                [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.headerView.mas_bottom);
                    make.leading.equalTo(self.headerView);
                }];
            } else {
                [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(previousButton);
                    make.leading.equalTo(previousButton.mas_trailing).offset(kTagButtonHorizontalSpacing);
                }];
            }
            [buttonsInRow addObject:currentButton];
        } else {
            if (!self.alreadyLayouted) {
                NSInteger buttonCountInRow = [buttonsInRow count];
                CGFloat bWidth = 0.0f;
                for (UIButton *button in buttonsInRow) {
                    bWidth += CGRectGetWidth(button.bounds);
                }
                CGFloat hSpacing = (MAX_ROW_WIDTH - bWidth - kTagButtonHorizontalSpacing * (buttonCountInRow - 1))/buttonCountInRow/2.0f - 1;
                for (int i = 0; i < buttonsInRow.count; i++) {
                    UIButton *btn = buttonsInRow[i];
                    btn.contentEdgeInsets = UIEdgeInsetsMake(5, 15 + hSpacing, 5, 15 + hSpacing);
                    [btn sizeToFit];
                }
                [buttonsInRow removeAllObjects];
                
                [buttonsInRow addObject:currentButton];
            }
            // new line
            currentWidth = 0.0f;
            [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.headerView);
                make.top.equalTo(previousButton.mas_bottom).offset(kTagButtonVerticalSpacing);
            }];
        }
        currentWidth += buttonWidth + kTagButtonHorizontalSpacing;
        previousButton = currentButton;
    }
    
    [_postButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(kFlyPostButtonHeight));
    }];
    
    if (_overlayView) {
        [_overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kNavBarHeight + kStatusBarHeight + kTitleTextCellHeight);
            make.leading.equalTo(self.view);
            make.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    
    self.alreadyLayouted = YES;
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
    NSDictionary *properties = @{kTrackingSection: @"post_page", kTrackingComponent:@"post",  kTrackingElement:@"post_button", kTrackingAction:@"click"};
    [[Mixpanel sharedInstance]  track:@"recording_flow" properties:properties];
    
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
    
    @weakify(self)
    FLYPostTopicSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        FLYTopic *post = [[FLYTopic alloc] initWithDictory:responseObj];
        NSDictionary *dict = @{kNewPostKey:post};
        [Dialog simpleToast:@"Posted"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewPostReceivedNotification object:self userInfo:dict];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.postButton.userInteractionEnabled = YES;
        
    };
    
    FLYPostTopicErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self)
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
