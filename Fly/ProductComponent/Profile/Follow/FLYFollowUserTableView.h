//
//  FLYFollowUserTableView.h
//  Flyy
//
//  Created by Xingxing Xu on 11/15/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLYFollowType) {
    FLYFollowTypeFollowing = 0,
    FLYFollowTypeFollower,
    FLYFollowTypeLeadboard
};

@interface FLYFollowUserTableView : UIView

- (instancetype)initWithType:(FLYFollowType)type;

@end
