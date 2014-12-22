//
//  FLYDownloadManager.m
//  Fly
//
//  Created by Xingxing Xu on 12/21/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYDownloadManager.h"
#import "FLYFileManager.h"
#import "AFHTTPRequestOperation.h"

#define kTimeoutInterval 20

@interface FLYDownloadManager()

@end

@implementation FLYDownloadManager

+ (instancetype)sharedInstance
{
    static FLYDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FLYDownloadManager new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _startDownloadQueue = dispatch_queue_create("com.flyyapp.startDownloadQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)loadAudioByURLString:(NSString *)urlStr
{
    dispatch_async(_startDownloadQueue, ^{
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *localPath = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[url.pathComponents componentsJoinedByString:@"_"]];
        NSString *downloadingPath = [localPath stringByAppendingString:@".part"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            return;
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = kTimeoutInterval;
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadingPath append:NO];
        
        [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
            return nil;
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] moveItemAtPath:downloadingPath toPath:localPath error:&error];
            if (!success) {
                //retry
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadCompleteNotification object:nil userInfo:@{@"localPath":localPath}];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //retry
            NSLog(@"failed to load");
        }];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//            NSLog(@"downloading");
        }];
        
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        operationQueue.maxConcurrentOperationCount = 1;
        [operationQueue addOperation:operation];
    });
}
@end
