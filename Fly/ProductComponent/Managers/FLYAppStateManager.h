//
//  FLYAppStateManager.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYAppStateManager : NSObject

@property (nonatomic) BOOL isAutoPlayEnabled;


+ (instancetype)sharedInstance;

@end
