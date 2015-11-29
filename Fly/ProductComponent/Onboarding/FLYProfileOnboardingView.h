//
//  FLYProfileOnboardingView.h
//  Flyy
//
//  Created by Xingxing Xu on 11/27/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYMainViewController;
@class FLYProfileViewController;

@interface FLYProfileOnboardingView : UIView

+ (UIView *)showFeedOnBoardViewWithMainVC:(FLYMainViewController *)mainVC inViewController:(FLYProfileViewController *)inViewController;

@end
