//
//  FLYLoginManager.h
//  Flyy
//
//  Created by Xingxing Xu on 7/31/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYLoginManager : NSObject

+ (instancetype)sharedInstance;

- (void)initAfterLogin;

@end
