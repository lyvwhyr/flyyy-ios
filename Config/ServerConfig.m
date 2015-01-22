//
//  ServerConfig.m
//  Confessly
//
//  Created by Xingxing Xu on 7/12/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

#import "ServerConfig.h"

@implementation ServerConfig

+(NSString *)getServerURL
{
//    ENV_TYPE type = ENV_STAGING;
//    ENV_TYPE type = ENV_DEV;
    ENV_TYPE type = ENV_PROD;
    
    NSString *serverURL;
    if (type == ENV_DEV) {
        serverURL = DEV_BASE_URL;
    } else if (type == ENV_STAGING) {
        serverURL = STAGING_BASE_URL;
    } else {
        serverURL = PROD_BASE_URL;
    }
    return serverURL;
}

@end
