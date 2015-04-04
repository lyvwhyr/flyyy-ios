//
//  FLYDownloadManager.h
//  Fly
//
//  Created by Xingxing Xu on 12/21/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYDownloadableAudio.h"

@interface FLYDownloadManager : NSObject {
    dispatch_queue_t _startDownloadQueue;
}

- (void)loadAudioByURLString:(NSString *)urlStr audioType:(FLYDownloadableAudioType)audioType;

+ (instancetype)sharedInstance;

@end
