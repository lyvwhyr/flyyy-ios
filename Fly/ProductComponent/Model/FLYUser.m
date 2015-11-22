//
//  FLYUser.m
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYGroup.h"
#import "FLYUsersService.h"

@implementation FLYUser

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict == nil) {
            return self;
        }
        _userId = [[dict fly_objectOrNilForKey:@"user_id"] stringValue];
        _userName = [dict fly_stringForKey:@"user_name"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];
        _suspended = [dict fly_boolForKey:@"suspended" defaultValue:NO];
        _tags = [NSMutableArray new];
        NSArray *tagsData = [dict fly_arrayForKey:@"tags"];
        for (NSDictionary *tagDict in tagsData) {
            FLYGroup *tag = [[FLYGroup alloc] initWithDictory:tagDict];
            [_tags addObject:tag];
        }
        
        _followingCount = [dict fly_integerForKey:@"followees"];
        _followerCount = [dict fly_integerForKey:@"followers"];
        _replyCount = [dict fly_integerForKey:@"replies"];
        _topicCount = [dict fly_integerForKey:@"topics"];
        _points = [dict fly_integerForKey:@"points"];
        _isFollowing = [dict fly_boolForKey:@"is_following"];
    }
    return self;
}

- (void)followUser
{
    // need to call serverFollow first so it can use the original values of a user.
    [self _serverFollow];
    [self _clientFollow];
}

- (void)_clientFollow
{
    self.isFollowing = !self.isFollowing;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowUserChanged object:self userInfo:@{@"user":self}];
}

- (void)_serverFollow
{
    FLYFollowUserByUserIdSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        
    };
    
    FLYFollowUserByUserIdErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        // revert follow
        [self _clientFollow];
    };
    
    [FLYUsersService followUserByUserId:self.userId isFollow:!self.isFollowing successBlock:successBlock error:errorBlock];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_userId forKey:@"user_id"];
    [coder encodeObject:_userName forKey:@"user_name"];
    [coder encodeObject:_createdAt forKey:@"created_at"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _userId = [aDecoder decodeObjectForKey:@"user_id"];
        _userName = [aDecoder decodeObjectForKey:@"user_name"];
        _createdAt = [aDecoder decodeObjectForKey:@"created_at"];
    }
    return self;
}

@end
