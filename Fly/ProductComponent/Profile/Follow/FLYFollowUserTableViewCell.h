//
//  FLYFollowUserTableViewCell.h
//  Flyy
//
//  Created by Xingxing Xu on 11/16/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYUser;

@interface FLYFollowUserTableViewCell : UITableViewCell

- (void)setupCellWithUser:(FLYUser *)user;

@end
