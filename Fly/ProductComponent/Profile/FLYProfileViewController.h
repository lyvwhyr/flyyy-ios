//
//  FLYProfileViewController.h
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@interface FLYProfileViewController : FLYUniversalViewController

@property (nonatomic) BOOL isSelf;

- (instancetype)initWithUserId:(NSString *)userId;

@end
