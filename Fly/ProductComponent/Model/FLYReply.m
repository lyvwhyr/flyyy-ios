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
#import "NSDate+TimeAgo.h"
#import "FLYDownloadableAudio.h"
#import "FLYReplyService.h"


@interface FLYReply()<FLYDownloadableAudio>

@end

@implementation FLYReply

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _topicId = [[dict fly_objectOrNilForKey:@"topic_id"] stringValue];
        _replyId = [[dict fly_objectOrNilForKey:@"reply_id"] stringValue];
        _parentReplyId = [[dict fly_objectOrNilForKey:@"parent_reply_id"] stringValue];
        if ([dict fly_dictionaryForKey:@"parent_reply_user"]) {
            _parentReplyUser = [[FLYUser alloc] initWithDictionary:[dict fly_dictionaryForKey:@"parent_reply_user"]];
        }
        _user = [[FLYUser alloc] initWithDictionary:[dict fly_dictionaryForKey:@"user"]];
        NSString *mediaPath = [dict fly_stringForKey:@"media_path"];
        _mediaURL = [NSString stringWithFormat:@"%@/%@", URL_ASSET_STAGING_BASE, mediaPath];
        _likeCount = [dict fly_integerForKey:@"like_count"];
        _audioDuration = [dict fly_integerForKey:@"audio_duration"];
        _createdAt = [[dict fly_objectOrNilForKey:@"created_at"] stringValue];        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[_createdAt longLongValue]/1000];
        NSString *ago = [date timeAgoSimple];
        _displayableCreateAt = ago;
        _liked = [dict fly_boolForKey:@"liked" defaultValue:NO];
    }
    return self;
}

#pragma mark - FLYDownloadableAudioDelegate
- (NSString *)audioURLStr
{
    return self.mediaURL;
}

- (FLYDownloadableAudioType)downloadableAudioType
{
    return FLYDownloadableReply;
}

- (void)like
{
    [self _serverLike:self.liked];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReplyLikeChanged object:self userInfo:@{@"reply":self}];
}

- (void)_serverLike:(BOOL)liked
{
    FLYReplyLikeSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        
    };
    
    FLYReplyLikeErrorBlock errorBlock = ^(id responseObj, NSError *error) {
        // revert like
        [self _clientLike:self.liked];
    };
    
    [FLYReplyService likeReplyWithId:self.replyId liked:liked successBlock:successBlock errorBlock:errorBlock];
}

@end
