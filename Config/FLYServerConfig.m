//
//  ServerConfig.m
//  Confessly
//
//  Created by Xingxing Xu on 7/12/14.
//  Copyright (c) 2014 Confess.ly. All rights reserved.
//

#import "FLYServerConfig.h"

@implementation FLYServerConfig

+ (ENV_TYPE)getEnv
{
    ENV_TYPE type = ENV_STAGING;
//        ENV_TYPE type = ENV_DEV;
//    ENV_TYPE type = ENV_PROD;
    return type;
}

+ (NSString *)getServerURL
{
    ENV_TYPE type = [FLYServerConfig getEnv];
    
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

+ (NSString *)getAssetURL
{
    ENV_TYPE type = [FLYServerConfig getEnv];
    NSString *assetURL;
    if (type == ENV_DEV) {
        assetURL = URL_ASSET_STAGING_BASE;
    } else if (type == ENV_STAGING) {
        assetURL = URL_ASSET_STAGING_BASE;
    } else {
        assetURL = URL_ASSET_PRODUCTION_BASE;
    }
    return assetURL;
}

@end
