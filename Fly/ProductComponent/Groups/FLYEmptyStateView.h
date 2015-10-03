//
//  FLYEmptyStateView.h
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FLYEmptyStateViewActionBlock)(void);

@interface FLYEmptyStateView : UIView

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description buttonText:(NSString *)buttonText actionBlock:(FLYEmptyStateViewActionBlock)actionBlock;

@end
