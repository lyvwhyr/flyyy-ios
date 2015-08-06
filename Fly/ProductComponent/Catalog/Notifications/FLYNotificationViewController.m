
//
//  FLYNotificationViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYNotificationViewController.h"
#import "FLYNotificationTableViewCell.h"

@interface FLYNotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *notificationTableView;

@property (nonatomic) NSMutableArray *entries;

@end

@implementation FLYNotificationViewController


- (instancetype)init
{
    if (self = [super init]) {
        _entries = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.notificationTableView = [UITableView new];
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    [self.view addSubview:self.notificationTableView];
}


# pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYNotificationTableViewCellCellIdentifier";
    FLYNotificationTableViewCell *cell = [self.notificationTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FLYNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}



@end
