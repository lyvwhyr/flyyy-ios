//
//  FLYGroupManager.h
//  Fly
//
//  Created by Xingxing Xu on 2/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYGroupManager : NSObject

@property (nonatomic) NSArray *groupList;

+ (instancetype)sharedInstance;

@end
