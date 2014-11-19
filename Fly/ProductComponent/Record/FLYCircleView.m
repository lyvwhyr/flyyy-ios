//
//  FLYCircleView.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FLYCircleView.h"
#import "UIColor+FLYAddition.h"

@implementation FLYCircleView

- (instancetype)initWithCenterPoint:(CGPoint)point
{
    if (self = [super init]) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:point radius:100 startAngle:0 endAngle:2 * M_PI clockwise:NO];
        CAShapeLayer *arcLayer = [CAShapeLayer layer];
        arcLayer.path = path.CGPath;
        arcLayer.strokeColor = [UIColor flyGreen].CGColor;
        arcLayer.fillColor = [UIColor flyGreen].CGColor;
//        arcLayer.fillColor = [UIColor whiteColor].CGColor;
        arcLayer.lineWidth = 5;
        [self.layer addSublayer:arcLayer];
        
//        [self drawLineAnimation:arcLayer];
    }
    return self;
}


-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=10;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}


@end
