//
//  NSMutableDictionary+FLYAddition.h
//  Flyy
//
//  Created by Xingxing Xu on 2/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (FLYAddition)

//If an object is empty, set it with empty string
- (void)setObjectOrEmptyStr:(id)object forKey:(NSString *)key;

@end
