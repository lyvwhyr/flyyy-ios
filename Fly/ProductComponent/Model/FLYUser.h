//
//  FLYUser.h
//  Fly
//
//  Created by Xingxing Xu on 1/29/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYUser : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic) BOOL suspended;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
