//
//  FLYEverythingElseViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 3/30/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

typedef NS_ENUM(NSInteger, FLYEverythingElseCellType) {
    FLYEverythingElseCellTypePosts = 0,
    FLYEverythingElseCellTypeReplies,
    FLYEverythingElseCellTypeSettings
};

@protocol FLYEverythingElseViewControllerDelegate <NSObject>

- (void)everythingElseCellTapped:(FLYUniversalViewController *)vc type:(FLYEverythingElseCellType)type;

@end

@interface FLYEverythingElseViewController : FLYUniversalViewController

@property (nonatomic) id<FLYEverythingElseViewControllerDelegate>delegate;

@end
