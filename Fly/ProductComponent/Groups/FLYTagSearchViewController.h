//
//  FLYTagSearchViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 8/23/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYTagListBaseViewController.h"
#import "FLYUniversalViewController.h"

@interface FLYTagSearchViewController : FLYUniversalViewController

@property (nonatomic) FLYTagListType tagListType;

- (instancetype)initWithSearchType:(FLYTagListType)type;

- (void)updateSearchText:(NSString *)searchText;

@end
