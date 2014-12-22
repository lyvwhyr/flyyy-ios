//
//  NSBundle+FLYAddition.h
//  Fly
//
//  Created by Xingxing Xu on 12/21/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOC(key) \
    [[NSBundle mainBundle] L:(key)]

@interface NSBundle (FLYAddition)

- (NSString *)L:(NSString *)translation_key;

@end
