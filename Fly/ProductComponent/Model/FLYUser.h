//
//  FLYUser.h
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYUser : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;

- (instancetype)initWithDictory:(NSDictionary *)dict;

@end
