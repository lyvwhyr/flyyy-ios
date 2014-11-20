//
//  FLYCircleView.h
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYCircleView : UIView

- (instancetype)initWithCenterPoint:(CGPoint)point radius:(CGFloat)radius color:(UIColor *)color;
- (void)setupLayerFillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor;

@end
