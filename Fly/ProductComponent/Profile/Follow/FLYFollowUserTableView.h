//
//  FLYFollowUserTableView.h
//  Flyy
//
//  Created by Xingxing Xu on 11/15/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYFollowUserTableView;
@class FLYUser;

typedef NS_ENUM(NSInteger, FLYFollowType) {
    FLYFollowTypeFollowing = 0,
    FLYFollowTypeFollower,
    FLYFollowTypeLeadboard
};

@protocol FLYFollowUserTableViewDelegate <NSObject>

- (void)tableCellTapped:(FLYFollowUserTableView *)tableView user:(FLYUser *)user;

@end

@interface FLYFollowUserTableView : UIView

@property (nonatomic, weak) id<FLYFollowUserTableViewDelegate> delegate;

- (instancetype)initWithType:(FLYFollowType)type userId:(NSString *)userId;

@end
