//
//  FLYGroupViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/30/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYGroupViewController.h"
#import "FLYFeedViewController.h"
#import "FLYBarButtonItem.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYGroup.h"
#import "FLYTopicService.h"
#import "FLYTagsService.h"
#import "FLYTagsManager.h"
#import "FLYShareTagView.h"
#import "FLYShareManager.h"
#import "Dialog.h"

@interface FLYGroupViewController ()
@property (nonatomic) UILabel *groupTitleLabel;
@property (nonatomic) FLYShareTagView *shareTagView;

@property (nonatomic) BOOL hasJoinedGroup;
@property (nonatomic) FLYGroup *group;

@end

@implementation FLYGroupViewController

@synthesize isFullScreen = _isFullScreen;

- (instancetype)initWithGroup:(FLYGroup *)group
{
    if (self = [super init]) {
        _group = group;
        [super setTopicService:[FLYTopicService topicsServiceWithGroupIds:self.group.groupId]];
        self.feedType = FLYFeedTypeGroup;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *displayName = [NSString stringWithFormat:@"#%@", self.group.groupName];
    self.shareTagView = [[FLYShareTagView alloc] initWithTitle:displayName];
    self.shareTagView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_shareTapped)];
    [self.shareTagView addGestureRecognizer:tapGestureRecognizer];
    
    self.navigationItem.titleView = self.shareTagView;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, [FLYShareTagView viewSize:displayName].width, [FLYShareTagView viewSize:displayName].height);
    
    [[FLYScribe sharedInstance] logEvent:@"group_page" section:nil component:nil element:nil action:@"impression"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [FLYAppStateManager sharedInstance].currentlyInGroup = self.group;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [FLYAppStateManager sharedInstance].currentlyInGroup = nil;
}

#pragma mark - Navigation bar
- (void)loadLeftBarButton
{
    if ([self.navigationController.viewControllers count] > 1) {
        FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _backButtonTapped];
        };
        self.navigationItem.leftBarButtonItem = barItem;
    }
}

- (void)loadRightBarButton
{
    _hasJoinedGroup = [[FLYTagsManager sharedInstance] alreadyFollowedTag:self.group];
    if (!_hasJoinedGroup) {
        FLYJoinTagButtonItem *barItem = [FLYJoinTagButtonItem barButtonItem:NO];
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            if ([FLYUtilities isInvalidUser]) {
                return;
            }
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.userInteractionEnabled = NO;
            HUD.textLabel.text = @"Joined";
            HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [HUD showInView:self.view];
            [HUD dismissAfterDelay:1.0];

            [[FLYTagsManager sharedInstance] updateCurrentUserTags:[NSMutableArray arrayWithObject:self.group]];
            [FLYTagsService followTagWithId:self.group.groupId followed:NO successBlock:nil errorBlock:nil];
            [self loadRightBarButton];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
        // unfollow
        FLYLeaveTagButtonItem *barItem = [FLYLeaveTagButtonItem barButtonItem:NO];
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            if ([FLYUtilities isInvalidUser]) {
                return;
            }
            
            [Dialog simpleToast:@"Left"];
            
            [[FLYTagsManager sharedInstance] unFollowTag:self.group];
            [FLYTagsService followTagWithId:self.group.groupId followed:YES successBlock:nil errorBlock:nil];
            [self loadRightBarButton];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    }
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

- (BOOL)hideLeftBarItem
{
    return YES;
}

-(void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_shareTapped
{
    NSString *tagName = [NSString stringWithFormat:@"#%@", self.group.groupName];
    [FLYShareManager shareTag:self tagName:tagName];
}

@end
