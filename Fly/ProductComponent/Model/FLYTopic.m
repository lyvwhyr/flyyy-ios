//
//  FLYPost.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTopic.h"
#import "FLYUser.h"
#import "FLYGroup.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYDownloadableAudio.h"
#import "FLYURLConstants.h"

@interface FLYTopic() <FLYDownloadableAudio>

@end

//@property (nonatomic, copy) NSString *topicId;
//@property (nonatomic, copy) NSString *topicTitle;
//@property (nonatomic) NSInteger likeCount;
//@property (nonatomic) NSInteger replyCount;
//@property (nonatomic) NSInteger audioDuration;
//@property (nonatomic, copy) NSString *createdAt;
//@property (nonatomic, copy) NSString *updatedAt;
//@property (nonatomic, copy) NSString *mediaURL;
//@property (nonatomic) FLYUser *user;
//@property (nonatomic) FLYGroup *group;


@implementation FLYTopic

- (instancetype)initWithDictory:(NSDictionary *)dict
{
    if (self = [super init]) {
        _topicId = [[dict fly_objectOrNilForKey:@"topic_id"] stringValue];
        _topicTitle = [dict fly_stringForKey:@"topic_title"];
        NSString *mediaPath = [dict fly_stringForKey:@"media_path"];
        _mediaURL = [URL_ASSET_STAGING_BASE stringByAppendingPathComponent:mediaPath];
        _likeCount = [dict fly_integerForKey:@"like_count"];
        _replyCount = [dict fly_integerForKey:@"reply_count"];
        _audioDuration = [dict fly_integerForKey:@"audio_duration"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];
        _updatedAt = [[dict fly_objectOrNilForKey:@"updated_at"] stringValue];
        _user = [[FLYUser alloc] initWithDictory:[dict fly_dictionaryForKey:@"user"]];
        _group = [[FLYGroup alloc] initWithDictory:[dict fly_dictionaryForKey:@"group"]];
        
        //TODO:remove
        NSInteger count = [dict fly_integerForKey:@"count"];
        _audioURLStr = [NSString stringWithFormat:@"https://ia601409.us.archive.org/6/items/new_concept_uk_level3/lesson_%.2d.mp3", (int)count];
    }
    return self;
}



@end
