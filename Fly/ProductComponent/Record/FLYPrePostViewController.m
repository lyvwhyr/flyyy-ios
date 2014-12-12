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

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"
#define kFlyPostButtonHeight 44

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) FLYPostButtonView *postButton;

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
        return 70;
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


@end
