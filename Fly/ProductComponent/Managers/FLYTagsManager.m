//
//  FLYTagsManager.m
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagsManager.h"
#import "FLYGroup.h"
#import "FLYUser.h"

@implementation FLYTagsManager

+ (instancetype)sharedInstance
{
    static FLYTagsManager *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [FLYTagsManager new];
    });
    return instance;
}

- (void)updateCurrentUserTags:(NSMutableArray *)tagsToMerge
{
    NSMutableArray *existingTags = [FLYAppStateManager sharedInstance].currentUser.tags;
    NSMutableArray *finalTags = [NSMutableArray arrayWithArray:existingTags];
    for (FLYGroup *tag in tagsToMerge) {
        if (![self _tagAlreadyExist:tag existingTags:existingTags]) {
            [finalTags addObject:tag];
        }
    }
    if (finalTags.count > existingTags.count) {
        // sort
        finalTags = [[finalTags sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            FLYGroup *g1 = obj1;
            FLYGroup *g2 = obj2;
            return [[g1.groupName lowercaseString] compare:[g2.groupName lowercaseString]];
        }] mutableCopy];
        
        [FLYAppStateManager sharedInstance].currentUser.tags = finalTags;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMyTagsUpdated object:self];
    }
}

- (void)unFollowTag:(FLYGroup *)tagToUnfollow
{
    NSMutableArray *existingTags = [FLYAppStateManager sharedInstance].currentUser.tags;
    if (!existingTags) {
        return;
    }
    for (FLYGroup *tag in existingTags) {
        if ([tag.groupId isEqualToString:tagToUnfollow.groupId]) {
            [existingTags removeObject:tag];
            break;
        }
    }
    [FLYAppStateManager sharedInstance].currentUser.tags = existingTags;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMyTagsUpdated object:self];
}

- (BOOL)alreadyFollowedTag:(FLYGroup *)tag
{
    NSMutableArray *followedTags = [FLYAppStateManager sharedInstance].currentUser.tags;
    if (!followedTags || followedTags.count == 0) {
        return NO;
    }
    for (FLYGroup *followedTag in followedTags) {
        if ([followedTag.groupId isEqualToString:tag.groupId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)_tagAlreadyExist:(FLYGroup *)tag existingTags:(NSMutableArray *)existingTags
{
    for (FLYGroup *existingTag in existingTags) {
        if ([existingTag.groupId isEqualToString:tag.groupId]) {
            return YES;
        }
    }
    return NO;
}

@end
