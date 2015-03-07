//
//  UIDevice+FLYAddition.m
//  Flyy
//
//  Created by Xingxing Xu on 2/14/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "UIDevice+FLYAddition.h"
#import "UICKeyChainStore.h"

#define kUniqueDeviceId @"uniqueId"

@implementation UIDevice (FLYAddition)

+ (NSString *)uniqueDeviceIdentifier
{
    NSString *deviceUUID = [UICKeyChainStore stringForKey:kUniqueDeviceId service:kKeyChainServiceURL];
    if (!deviceUUID) {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        deviceUUID = [NSString stringWithFormat:@"%@",[NSString stringWithString:(__bridge_transfer NSString *)uuidStringRef]];
        [UICKeyChainStore setString:deviceUUID forKey:kUniqueDeviceId service:kKeyChainServiceURL];
    }
    return deviceUUID;
}

@end
