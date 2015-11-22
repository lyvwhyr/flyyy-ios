//
//  FLYBadgeHelper.m
//  Flyy
//
//  Created by Xingxing Xu on 11/21/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYBadgeHelper.h"

@implementation FLYBadgeHelper

+ (NSInteger)getLevelForPoints:(NSInteger)points
{
    if (points >= 400) {
        return 5;
    } else if (points >= 200) {
        return 4;
    } else if (points >= 100) {
        return 3;
    } else if (points >= 50) {
        return 2;
    } else {
        return 1;
    }
}

@end
