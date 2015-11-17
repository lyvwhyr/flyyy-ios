//
//  FLYFollowUserTableView.m
//  Flyy
//
//  Created by Xingxing Xu on 11/15/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYFollowUserTableView.h"
#import "SVPullToRefresh.h"
#import "FLYFollowUserTableViewCell.h"

@interface FLYFollowUserTableView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) FLYFollowType type;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableArray *entries;
@property (nonatomic) NSString *cursor;

@end

@implementation FLYFollowUserTableView

- (instancetype)initWithType:(FLYFollowType)type
{
    if (self = [super init]) {
        _type =type;
        _entries = [NSMutableArray new];
        
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        
        
        @weakify(self)
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            @strongify(self)
//            [self _load:NO before:self.cursor cursor:YES];
        }];
    }
    return self;
}

- (void)updateConstraints
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [super updateConstraints];
}


#pragma mark - UITableViewDatasource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
    //return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYEverythingElseCell";
    FLYFollowUserTableViewCell *cell = [[FLYFollowUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


@end
