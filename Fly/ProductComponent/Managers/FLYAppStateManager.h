//
//  FLYAppStateManager.h
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@interface FLYAppStateManager : NSObject

@property (nonatomic) BOOL isAutoPlayEnabled;
@property (nonatomic) NSString *recordingFilePath;


+ (instancetype)sharedInstance;

@end
