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
@property (nonatomic, copy) NSString *recordingFilePath;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic) NSArray *groupList;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic) FLYUser *currentUser;

//Phone sign up
@property (nonatomic, copy) NSString *phoneHash;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *confirmationCode;

//auth token
@property (nonatomic, copy) NSString *authToken;

+ (instancetype)sharedInstance;

@end
