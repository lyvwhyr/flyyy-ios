//
//  FLYFeedOnBoardingView.h
//  Flyy
//
//  Created by Xingxing Xu on 4/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

@class FLYFeedTopicTableViewCell;

@interface FLYFeedOnBoardingView : UIView

@property (nonatomic) FLYFeedTopicTableViewCell *cellToExplain;
@property (nonatomic) UIView *showInView;


+ (UIView *)showFeedOnBoardViewInView:(UIView *)inView cellToExplain:(FLYFeedTopicTableViewCell *)cell;

@end
