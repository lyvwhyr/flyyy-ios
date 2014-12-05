//
//  FLYFeedDelegate.m
//  Fly
//
//  Created by Xingxing Xu on 12/2/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFeedDelegate.h"
#import "FLYSingleGroupViewController.h"

@implementation FLYFeedDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellClicked];
}

@end
