//
//  FLYUsernameSearchViewController.h
//  Flyy
//
//  Created by Xingxing Xu on 11/26/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@protocol FLYUsernameSearchViewControllerDelegate <NSObject>

- (UIViewController *)rootViewController;

@end

@interface FLYUsernameSearchViewController : FLYUniversalViewController

@property (nonatomic, weak) id<FLYUsernameSearchViewControllerDelegate> delegate;

- (void)updateSearchText:(NSString *)searchText;

@end
