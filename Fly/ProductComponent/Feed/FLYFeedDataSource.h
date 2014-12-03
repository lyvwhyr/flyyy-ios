//
//  FLYFeedDataSource.h
//  Fly
//
//  Created by Xingxing Xu on 12/2/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYFeedDataSource : NSObject<UITableViewDataSource>

- (id)initWithPosts:(NSMutableArray *)items;

@end
