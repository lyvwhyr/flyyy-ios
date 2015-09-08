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

@interface FLYGroupViewController ()
@property (nonatomic) UILabel *groupTitleLabel;

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
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = [NSString stringWithFormat:@"#%@", self.group.groupName];
    
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
        FLYAddGroupBarButtonItem *barItem = [FLYAddGroupBarButtonItem barButtonItem:NO];
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            if ([FLYUtilities isInvalidUser]) {
                return;
            }
            JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.textLabel.text = @"Followed";
            HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [HUD showInView:self.view];
            [HUD dismissAfterDelay:2.0];

            [[FLYTagsManager sharedInstance] updateCurrentUserTags:[NSMutableArray arrayWithObject:self.group]];
            [FLYTagsService followTagWithId:self.group.groupId followed:NO successBlock:nil errorBlock:nil];
            [self loadRightBarButton];
        };
        self.navigationItem.rightBarButtonItem = barItem;
    } else {
        // unfollow
        FLYJoinedGroupBarButtonItem *barItem = [FLYJoinedGroupBarButtonItem barButtonItem:NO];
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            if ([FLYUtilities isInvalidUser]) {
                return;
            }
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

@end
