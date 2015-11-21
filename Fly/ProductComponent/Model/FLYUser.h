//
//  FLYUser.h
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYUser : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic) BOOL suspended;
@property (nonatomic) NSMutableArray *tags;
@property (nonatomic) NSInteger followingCount;
@property (nonatomic) NSInteger followerCount;
@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger topicCount;
@property (nonatomic) NSInteger points;
@property (nonatomic) BOOL isFollowing;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)followUser;

@end
