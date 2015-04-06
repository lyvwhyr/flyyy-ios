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
@property (nonatomic) NSArray *groupList;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic) FLYUser *currentUser;

@property (nonatomic, copy) NSString *recordingFilePath;
@property (nonatomic, copy) NSString *recordingFilePathFiltred;
@property (nonatomic, copy) NSString *recordingFilePathSelected;

//Phone sign up
@property (nonatomic, copy) NSString *phoneHash;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *confirmationCode;

//auth token
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *userDefaultUserId;

//server configs
@property (nonatomic) NSMutableDictionary *configs;

// need reset navigation stack after login. After logout and relogin, we cannnot just dimiss the login view because it will not end in home page.
@property (nonatomic) BOOL needRestartNavigationStackAfterLogin;

// signed url for upload
@property (nonatomic, copy) NSString *signedURLString;
@property (nonatomic, copy) NSString *mineType;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic) BOOL mediaAlreadyUploaded;

+ (instancetype)sharedInstance;

- (void)clearSignedMedia;

@end
