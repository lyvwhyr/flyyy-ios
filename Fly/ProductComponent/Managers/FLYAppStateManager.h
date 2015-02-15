//
//  FLYAppStateManager.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@class FLYUser;

@interface FLYAppStateManager : NSObject

@property (nonatomic) BOOL isAutoPlayEnabled;
@property (nonatomic) NSString *recordingFilePath;
@property (nonatomic) NSString *mediaId;
@property (nonatomic) NSArray *groupList;
@property (nonatomic) NSString *deviceToken;
@property (nonatomic) NSString *deviceId;
@property (nonatomic) FLYUser *currentUser;


+ (instancetype)sharedInstance;

@end
