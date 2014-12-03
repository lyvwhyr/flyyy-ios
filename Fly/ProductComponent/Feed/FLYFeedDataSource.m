//
//  FLYFeedDataSource.m
//  Fly
//
//  Created by Xingxing Xu on 12/2/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedDataSource.h"
#import "FLYFeedTopicTableViewCell.h"

@interface FLYFeedDataSource()

@property (nonatomic) NSMutableArray *posts;

@end

@implementation FLYFeedDataSource

- (id)init
{
    return nil;
}

- (id)initWithPosts:(NSMutableArray *)items
{
    if (self = [super init]) {
        _posts = [NSMutableArray new];
        _posts = [items mutableCopy];
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"feedPostCellIdentifier";
    FLYFeedTopicTableViewCell *cell = (FLYFeedTopicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYFeedTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
