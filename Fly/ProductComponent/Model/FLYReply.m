//
//  FLYReply.m
//  Flyy
//
//  Created by Xingxing Xu on 2/15/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYReply.h"
#import "FLYUser.h"
#import "NSDictionary+FLYAddition.h"

@implementation FLYReply

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _topicId = [[dict fly_objectOrNilForKey:@"topic_id"] stringValue];
        _replyId = [[dict fly_objectOrNilForKey:@"reply_id"] stringValue];
        _parentReplyId = [[dict fly_objectOrNilForKey:@"parent_reply_id"] stringValue];
        _parentReplyUser = [[FLYUser alloc] initWithDictionary:[dict fly_dictionaryForKey:@"parent_reply_user"]];
        _user = [[FLYUser alloc] initWithDictionary:[dict fly_dictionaryForKey:@"user"]];
        NSString *mediaPath = [dict fly_stringForKey:@"media_path"];
        _mediaURL = [NSString stringWithFormat:@"%@/%@", URL_ASSET_STAGING_BASE, mediaPath];
        _likeCount = [dict fly_integerForKey:@"like_count"];
        _duration = [dict fly_integerForKey:@"duration"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];
    }
    return self;
}

@end
