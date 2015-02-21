//
//  FLYDownloadableAudio.h
//  Fly
//
//  Created by Xingxing Xu on 12/23/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLYDownloadableAudioType) {
    FLYDownloadableTopic = 0,
    FLYDownloadableReply
};

@protocol FLYDownloadableAudio <NSObject>

- (NSString *)audioURLStr;
- (FLYDownloadableAudioType)downloadableAudioType;

@end
