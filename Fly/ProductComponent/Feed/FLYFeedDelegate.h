//
//  FLYFeedDelegate.h
//  Fly
//
//  Created by Xingxing Xu on 12/2/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLYFeedViewControllerDelegate <NSObject>

- (void)cellClicked;

@end

@interface FLYFeedDelegate : NSObject <UITableViewDelegate>

@property (nonatomic, weak) id<FLYFeedViewControllerDelegate> delegate;

@end
