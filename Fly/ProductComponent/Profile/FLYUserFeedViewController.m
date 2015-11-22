//
//  FLYUserFeedViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 11/22/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYUserFeedViewController.h"
#import "FLYBarButtonItem.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYTopicService.h"

@interface FLYUserFeedViewController ()

@end

@implementation FLYUserFeedViewController

@synthesize isFullScreen = _isFullScreen;

- (instancetype)initWithUserId:(NSString *)userId
{
    if (self = [super init]) {
        [super setTopicService:[FLYTopicService topicsByUserId:userId]];
        self.feedType = FLYFeedTypeOhtersPosts;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    self.title = @"Posts";
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

- (BOOL)hideLeftBarItem
{
    return YES;
}

- (BOOL)isFullScreen
{
    return _isFullScreen;
}

-(void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
