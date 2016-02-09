//
//  FLYNotification.m
//  Flyy
//
//  Created by Xingxing Xu on 8/5/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYNotification.h"
#import "NSDictionary+FLYAddition.h"
#import "FLYNotificationActor.h"
#import "FLYTopic.h"
#import "FLYUser.h"
#import "NSDate+TimeAgo.h"
#import "UIFont+FLYAddition.h"

/*
 "activities": [
 {
 "action": "replied",
 "actors": [
 {
 "created_at": 1437975251109,
 "user_id": 1473637262426275392,
 "user_name": "Apricot"
 },
 {
 "created_at": 1437975251320,
 "user_id": 1473637264194994394,
 "user_name": "Banana"
 },
 {
 "created_at": 1437975251727,
 "user_id": 1473637267610803480,
 "user_name": "Blueberry"
 },
 {
 "created_at": 1437975251925,
 "user_id": 1473637269273670623,
 "user_name": "Cherry"
 }
 ],
 "topic": {
 "audio_duration": 31,
 "created_at": 1437975252099,
 "group": {
 "group_id": 1395316850313382955,
 "group_name": "Funny"
 },
 "like_count": 1,
 "liked": false,
 "media_path": "9123542131682322157.m4a",
 "reply_count": 11,
 "topic_id": 1473637270735356027,
 "topic_title": "This is a test",
 "updated_at": 1437975252099,
 "user": {
 "created_at": 1437975251530,
 "user_id": 1473637265962856748,
 "user_name": "Blackberry"
 }
 },
 "updated_at": 1437975254366,
 "user": {
 "created_at": 1437975251530,
 "user_id": 1473637265962856748,
 "user_name": "Blackberry"
 }
 },
 */

@interface FLYNotification()


@end

@implementation FLYNotification

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _action = [dict fly_stringForKey:@"action"];
        if ([_action isEqualToString:kFLYNotificationTypeReplyLiked]) {
            _topic = [[FLYTopic alloc] initWithDictory:[[dict fly_dictionaryForKey:@"reply"] fly_dictionaryForKey:@"topic"]];
        } else {
            _topic = [[FLYTopic alloc] initWithDictory:[dict fly_dictionaryForKey:@"topic"]];
        }
        _actors = [[dict fly_arrayForKey:@"actors"] mutableCopy];
        _isRead = [dict fly_boolForKey:@"read"];
        
        _createdAt = [[dict fly_objectOrNilForKey:@"updated_at"] stringValue];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[_createdAt longLongValue]/1000];
        NSString *ago = [date timeAgoSimple];
        _displayableCreateAt = ago;
    }
    return self;
}


- (NSMutableAttributedString *)notificationString
{
    NSString *result;
    NSMutableAttributedString *attrStr;
    NSString *tempStr;
    if ([self.actors count] == 1) {
        NSString *username = [self.actors[0] fly_stringForKey:@"user_name"];
        if ([self.action isEqualToString:kFLYNotificationTypeReplied]) {
            tempStr = LOC(@"FLYSinglePersonRepliedActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeFollowed]) {
            tempStr = LOC(@"FLYSinglePersonFollowActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeMention]) {
            tempStr = LOC(@"FLYSinglePersonMentionActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeTopicLiked]) {
            tempStr = LOC(@"FLYSinglePersonLikeTopicActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeReplyLiked]) {
            tempStr = LOC(@"FLYSinglePersonLikeReplyActivity");
        }
        if (tempStr) {
            result = [NSString stringWithFormat:tempStr, username, self.topic.topicTitle];
            attrStr = [[NSMutableAttributedString alloc] initWithString:result];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, result.length)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username]];
        }
    } else if ([self.actors count] == 2) {
        NSString *username1 = [self.actors[0] fly_stringForKey:@"user_name"];
        NSString *username2 = [self.actors[1] fly_stringForKey:@"user_name"];
        if ([self.action isEqualToString:kFLYNotificationTypeReplied]) {
            tempStr = LOC(@"FLYTwoPersonRepliedActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeMention]) {
            tempStr = LOC(@"FLYTwoPersonMentionActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeTopicLiked]) {
            tempStr = LOC(@"FLYTwoPersonLikeTopicActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeReplyLiked]) {
            tempStr = LOC(@"FLYTwoPersonLikeReplyActivity");
        }
        if (tempStr) {
            result = [NSString stringWithFormat:tempStr, username1, username2, self.topic.topicTitle];
            attrStr = [[NSMutableAttributedString alloc] initWithString:result];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, result.length)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username1]];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username2]];
        }
    } else if ([self.actors count] == 3) {
        NSString *username1 = [self.actors[0] fly_stringForKey:@"user_name"];
        NSString *username2 = [self.actors[1] fly_stringForKey:@"user_name"];
        NSString *username3 = [self.actors[2] fly_stringForKey:@"user_name"];
        if ([self.action isEqualToString:kFLYNotificationTypeReplied]) {
            tempStr = LOC(@"FLYThreePersonRepliedActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeMention]) {
            tempStr = LOC(@"FLYThreePersonMentionActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeTopicLiked]) {
            tempStr = LOC(@"FLYThreePersonLikeTopicActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeReplyLiked]) {
            tempStr = LOC(@"FLYThreePersonLikeReplyActivity");
        }
        if (tempStr) {
            result = [NSString stringWithFormat:tempStr, username1, username2, username3, self.topic.topicTitle];
            attrStr = [[NSMutableAttributedString alloc] initWithString:result];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, result.length)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username1]];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username2]];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username3]];
        }
    } else {
        NSString *username1 = [self.actors[0] fly_stringForKey:@"user_name"];
        NSString *username2 = [self.actors[1] fly_stringForKey:@"user_name"];
        NSInteger otherCount = self.actors.count - 2;
        if ([self.action isEqualToString:kFLYNotificationTypeReplied]) {
            tempStr = LOC(@"FLYMoreThanThreePeopleRepliedActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeMention]) {
            tempStr = LOC(@"FLYMoreThanThreePeopleMentionActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeTopicLiked]) {
            tempStr = LOC(@"FLYMoreThanThreePeopleLikeTopicActivity");
        } else if ([self.action isEqualToString:kFLYNotificationTypeReplyLiked]) {
            tempStr = LOC(@"FLYMoreThanThreePeopleLikeReplyActivity");
        }
        if (tempStr) {
            result = [NSString stringWithFormat:tempStr, username1, username2, otherCount, self.topic.topicTitle];
            attrStr = [[NSMutableAttributedString alloc] initWithString:result];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Roman" size:16] range:NSMakeRange(0, result.length)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username1]];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:16] range:[result rangeOfString:username2]];
        }
    }
    if ([self _shouldAddTopicTitleForAction:self.action]) {
       [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-MediumItalic" size:16] range:[result rangeOfString:self.topic.topicTitle]];
    }
    return attrStr;
}

- (BOOL)_shouldAddTopicTitleForAction:(NSString *)action
{
    if ([action isEqualToString:kFLYNotificationTypeReplied] ||
            [action isEqualToString:kFLYNotificationTypeMention] ||
                [action isEqualToString:kFLYNotificationTypeTopicLiked] ||
                    [action isEqualToString:kFLYNotificationTypeReplyLiked]) {
        return YES;
    }
    return NO;
}

@end
