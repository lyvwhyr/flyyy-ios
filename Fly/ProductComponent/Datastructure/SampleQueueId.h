//
//  SampleQueueId.h
//  ExampleApp
//
//  Created by Thong Nguyen on 20/01/2014.
//  Copyright (c) 2014 Thong Nguyen. All rights reserved.
//


typedef NS_ENUM(NSInteger, FLYPlayableItemType) {
    FLYPlayableItemFeedTopic =0,
    FLYPlayableItemDetailTopic,
    FLYPlayableItemDetailReply,
    FLYPlayableItemRecording
};


@interface SampleQueueId : NSObject
@property (readwrite) int count;
@property (readwrite) NSURL* url;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) FLYPlayableItemType itemType;

-(id) initWithUrl:(NSURL*)url andCount:(int)count indexPath:(NSIndexPath *)indexPath itemType:(FLYPlayableItemType)itemType;

@end
