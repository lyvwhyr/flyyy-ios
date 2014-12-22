//
//  FLYFileManager.h
//  Fly
//
//  Created by Xingxing Xu on 12/22/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYFileManager : NSObject

+ (instancetype)sharedInstance;
+ (NSString *)audioCacheDirectory;

@end
