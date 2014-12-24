//
//  FLYPost.h
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYPost : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *postAt;
@property (nonatomic, copy) NSString *audioURLStr;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic) NSInteger replyCount;
@property (nonatomic) NSInteger audioLength;
@property (nonatomic) BOOL isAudioDownloaded;

- (instancetype)initWithDictory:(NSDictionary *)dict;

@end
