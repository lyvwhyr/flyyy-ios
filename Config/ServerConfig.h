//
//  ServerConfig.h
//  Confessly
//
//  Created by Xingxing Xu on 7/12/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ENV_TYPE) {
    ENV_DEV = 0,
    ENV_STAGING,
    ENV_PROD
};

@interface ServerConfig : NSObject


+(NSString *)getServerURL;

@end
