//
//  FLYTabBarView.h
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@protocol FLYTabBarViewDelegate <NSObject>

- (void)tabItemClicked:(NSInteger) index;

@end

@interface FLYTabBarView : UIView

@property (nonatomic, weak) id<FLYTabBarViewDelegate> delegate;
@property (nonatomic) NSArray *tabViews;

@end
