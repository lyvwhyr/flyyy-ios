//
//  FLYTagListBaseViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 9/6/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

typedef NS_ENUM(NSUInteger, FLYTagListType) {
    FLYTagListTypeMine = 0,
    FLYTagListTypeGlobal
};

@class FLYTagListViewController;

@protocol FLYTagListBaseViewControllerDelegate

- (UIViewController *)rootViewController;

@end

@interface FLYTagListBaseViewController : FLYUniversalViewController

@property (nonatomic) FLYTagListViewController *controller;
@property (nonatomic, weak) id<FLYTagListBaseViewControllerDelegate> delegate;

- (instancetype)initWithTagListType:(FLYTagListType)type;

@end
