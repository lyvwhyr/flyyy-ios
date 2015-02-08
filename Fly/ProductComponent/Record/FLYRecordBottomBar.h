//
//  FLYRecordBottomBar.h
//  Fly
//
//  Created by Xingxing Xu on 2/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLYRecordBottomBarDelegate <NSObject>

- (void)trashButtonTapped:(UIButton *)button;
- (void)nextButtonTapped:(UIButton *)button;

@end

@interface FLYRecordBottomBar : UIView

@property id<FLYRecordBottomBarDelegate> delegate;

@end
