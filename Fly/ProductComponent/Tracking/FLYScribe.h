//
//  FLYScribe.h
//  Flyy
//
//  Created by Xingxing Xu on 2/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYScribe : NSObject

+ (instancetype)sharedInstance;

- (void)logEvent:(NSString *)event section:(NSString *)section component:(NSString *)component element:(NSString *)element action:(NSString *)action;

@end
