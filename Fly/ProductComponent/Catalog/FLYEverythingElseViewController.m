//
//  FLYEverythingElseViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYEverythingElseViewController.h"
#import "FLYEverythingElseCell.h"

typedef NS_ENUM(NSInteger, FLYCellType) {
    FLYCellTypePosts = 0,
    FLYCellTypeReplies,
    FLYCellTypeSettings
};

#define kNumberOfItems 3

@interface FLYEverythingElseViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@end

@implementation FLYEverythingElseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorInset = UIEdgeInsetsZero;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self _addViewConstraints];
}

#pragma mark - UITableViewDelegate

- (FLYEverythingElseCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYEverythingElseCell";
    FLYEverythingElseCell *cell = [[FLYEverythingElseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    switch (indexPath.row) {
        case FLYCellTypePosts: {
            [cell configCellWithImage:@"icon_everything_else_my_posts" text:LOC(@"FLYEverythingElseMyPosts")];
            break;
        }
        case FLYCellTypeReplies: {
            [cell configCellWithImage:@"icon_everything_else_my_replies" text:LOC(@"FLYEverythingElseMyReplies")];
            break;
        }
        case FLYCellTypeSettings: {
            [cell configCellWithImage:@"icon_everything_else_settings" text:LOC(@"FLYEverythingElseSettings")];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 44 - segmented control height
    return (CGRectGetHeight([UIScreen mainScreen].bounds) - kStatusBarHeight - kNavBarHeight - 44)/kNumberOfItems;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfItems;
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

- (void)_addViewConstraints
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
