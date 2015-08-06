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

@property (nonatomic, copy) NSString *action;
@property (nonatomic) NSMutableArray *actors;

@end

@implementation FLYNotification

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _action = [dict fly_stringForKey:@"action"];
        
    }
    return self;
}


- (NSString *)getNotificationString
{
    return @"";
}

@end
