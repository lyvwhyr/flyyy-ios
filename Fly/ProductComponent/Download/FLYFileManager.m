//
//  FLYFileManager.m
//  Fly
//
//  Created by Xingxing Xu on 12/22/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFileManager.h"
#import <sys/stat.h>
#import <time.h>

static const CGFloat kCacheCleanInterval = 300;  //5 mins
static const NSInteger kCachMaxSize = 256 * 1024 * 1024;  //256M

@interface FLYFileManager()

@property (nonatomic) NSTimer *cacheCleanupTimer;
@property (nonatomic) dispatch_queue_t cacheCleanupQueue;
@property (nonatomic) NSFileManager *cleanupFileManager;

@end

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

- (instancetype)init
{
    if (self = [super init]) {
        _cacheCleanupQueue = dispatch_queue_create("com.flyy.cacheCleanupQueue", DISPATCH_QUEUE_SERIAL);
        _cacheCleanupTimer = [NSTimer scheduledTimerWithTimeInterval:kCacheCleanInterval target:self selector:@selector(_cleanCache) userInfo:nil repeats:YES];
        
        _cleanupFileManager = [[NSFileManager alloc] init];
        [self _cleanCache];
    }
    return self;
}

- (void)dealloc
{
    UALog(@"dealloced");
}

- (void)_cleanCache
{
    float currentAudioCacheSize = [self currentAudioCacheSize];
    UALog(@"cache size: %.2f", currentAudioCacheSize/1024/1024);
    dispatch_async(_cacheCleanupQueue, ^{
        [self _cleanupCacheHelper];
    });
}

- (void)debugPrintFilesAndSizeForDirectory:(NSString *)directory
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    for (int i = 0; files && (i < files.count); i++) {
        NSString *filePath = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:files[i]];
        NSDictionary *attributes = [_cleanupFileManager attributesOfItemAtPath:filePath error:nil];
        NSInteger fileSize = [attributes[NSFileSize] integerValue];
        NSString *fileName = [[filePath componentsSeparatedByString:@"/"] lastObject];
        //UALog(@"File name: %@, size %.2fk", fileName, fileSize/1024.0);
    }
}

- (void)_cleanupCacheHelper
{
    NSInteger currentSize = [self currentAudioCacheSize];
    if (currentSize <= kCachMaxSize) {
        return;
    }
    
    NSString *audioDir = [FLYFileManager audioCacheDirectory];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:audioDir error:nil];
    //after sort, oldest file at the beginning of the array.
    files = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *audio1, NSString *audio2) {
        struct stat stat1;
        struct stat stat2;
        
        NSString *path1 = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:audio1];
        NSString *path2 = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:audio2];
        
        stat([path1 UTF8String], &stat1);
        stat([path2 UTF8String], &stat2);
        return stat1.st_atimespec.tv_sec > stat2.st_atimespec.tv_sec;
    }];
    UALog(@"before: %@", files);
    for (int i = 0; i < (files && files.count); i++) {
        NSString *filePath = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:files[i]];
        NSDictionary *attributes = [_cleanupFileManager attributesOfItemAtPath:filePath error:nil];
        if ([self _isAudioWithAttributes:attributes fileName:files[i]]) {
            NSError *error;
            [_cleanupFileManager removeItemAtPath:filePath error:&error];
            if (error) {
                UALog(@"Delete file failed: %ld", error.code);
                return;
            }
            currentSize -= [attributes[NSFileSize] integerValue];
            if (currentSize <= kCachMaxSize) {
                UALog(@"after size %.2f", [self currentAudioCacheSize]/1024/1024.0);
                return;
            }
        }
    }
    UALog(@"after size %.2f", [self currentAudioCacheSize]/1024/1024.0);
}

- (NSInteger)currentAudioCacheSize
{
    NSString *audioDirectoryPath = [FLYFileManager audioCacheDirectory];
    NSInteger size = 0;
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:audioDirectoryPath error:&error];
    if (error) {
        UALog(@"Cannot get list of files %ld", error.code);
        return 0;
    }
    for (NSString *file in files) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[audioDirectoryPath stringByAppendingPathComponent:file] error:nil];
        if ([attributes[NSFileType] isEqualToString:NSFileTypeRegular] && ([[file pathExtension] isEqualToString:@"mp3"] || [[file pathExtension] isEqualToString:@"part"])) {
            size += [attributes[NSFileSize] integerValue];
        }
    }
    return size;
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

- (BOOL)_isAudioWithAttributes:(NSDictionary *)attributes fileName:(NSString *)fileName
{
    if ([attributes[NSFileType] isEqualToString:NSFileTypeRegular] &&
        ([[fileName pathExtension] isEqualToString:@"m4a"] || [[fileName pathExtension] isEqualToString:@"part"])) {
        return YES;
    }
    return NO;
}

@end
