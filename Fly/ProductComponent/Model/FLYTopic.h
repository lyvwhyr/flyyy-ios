//
//  FLYPost.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

/*
 {
 "topic_id": 3904935842495202788,
 "user": {
 "user_id": 123456,
 "user_name": "yo"
 },
 "group": {
 "group_id": 12345,
 "group_name": "love"
 },
 "topic_title": "abc",
 "media_path": "418819451816822124.m4a",
 "like_count": 0,
 "reply_count": 0,
 "audio_duration": 10,
 "created_at": 1422599848,
 "updated_at": 1422599848
 }
*/

@class FLYUser;
@class FLYGroup;

@interface FLYTopic : NSObject

@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger audioDuration;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *displayableCreateAt;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSString *mediaURL;
@property (nonatomic) BOOL liked;

@property (nonatomic) FLYUser *user;
@property (nonatomic) NSMutableArray *tags;

@property (nonatomic) BOOL isAudioDownloaded;

- (instancetype)initWithDictory:(NSDictionary *)dict;
- (void)like;
- (void)incrementReplyCount:(NSDictionary *)dict;
- (void)decrementReplyCount:(NSDictionary *)dict;

@end
