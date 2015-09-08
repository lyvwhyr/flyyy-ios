//
//  FLYTagsManager.h
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYTagsManager : NSObject

+ (instancetype)sharedInstance;
- (void)updateCurrentUserTags:(NSMutableArray *)tagsToMerge;

@end
