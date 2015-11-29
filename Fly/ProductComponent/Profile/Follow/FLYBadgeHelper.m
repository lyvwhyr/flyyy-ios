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
    if (points >= 10000000) {
        return 10;
    } else if (points >= 9000000) {
        return 9;
    } else if (points >= 400) {
        return 8;
    } else if (points >= 200) {
        return 7;
    } else if (points >= 100) {
        return 6;
    } else if (points >= 50) {
        return 5;
    } else if (points >= 10) {
        return 4;
    } else if (points >= 5) {
        return 3;
    } else if (points >= 1) {
        return 2;
    } else {
        return 1;
    }
}

@end
