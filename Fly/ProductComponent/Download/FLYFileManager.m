//
//  FLYFileManager.m
//  Fly
//
//  Created by Xingxing Xu on 12/22/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFileManager.h"

@implementation FLYFileManager

+ (instancetype)sharedInstance
{
    static FLYFileManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FLYFileManager new];
    });
    return instance;
}

+ (NSString *)audioCacheDirectory
{
    NSString *audioCacheDirectory;
    static NSArray *cacheDirectories = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    });
    audioCacheDirectory = [cacheDirectories[0] stringByAppendingPathComponent:kAudioCacheFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioCacheDirectory]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:audioCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            NSLog(@"create directory failed");
        }
    }
    return audioCacheDirectory;
}

@end
