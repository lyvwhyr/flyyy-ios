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
#import "NSDate+TimeAgo.h"
#import "FLYTopicService.h"

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
        _mediaURL = [NSString stringWithFormat:@"%@/%@", URL_ASSET_STAGING_BASE, mediaPath];
        _likeCount = [dict fly_integerForKey:@"like_count"];
        _replyCount = [dict fly_integerForKey:@"reply_count"];
        _audioDuration = [dict fly_integerForKey:@"audio_duration"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];
        _updatedAt = [[dict fly_objectOrNilForKey:@"updated_at"] stringValue];
        _user = [[FLYUser alloc] initWithDictionary:[dict fly_dictionaryForKey:@"user"]];
        _group = [[FLYGroup alloc] initWithDictory:[dict fly_dictionaryForKey:@"group"]];
        _liked = [dict fly_boolForKey:@"liked" defaultValue:0];
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[_createdAt longLongValue]/1000];
        NSString *ago = [date timeAgo];
        _displayableCreateAt = ago;
    }
    return self;
}

- (NSString *)audioURLStr
{
    return self.mediaURL;
}

- (FLYDownloadableAudioType)downloadableAudioType
{
    return FLYDownloadableTopic;
}

- (void)like
{
    if (self.liked) {
        [self _clientLike:self.liked];
    } else {
        [self _clientLike:self.liked];
    }
}

- (void)_clientLike:(BOOL)liked
{
    if (self.liked) {
        if (liked >= 1) {
            self.likeCount -= 1;
        }
    } else {
        self.likeCount += 1;
    }
    self.liked = !liked;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTopicLikeChanged object:self userInfo:@{@"topic":self}];
}

- (void)serverLike:(BOOL)liked
{
    FLYLikeSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        UALog(@"liked");
    };
    
    FLYLikeErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        
    };
    
    [FLYTopicService likeTopicWithId:self.topicId liked:liked successBlock:successBlock errorBlock:errorBlock];
}



@end
