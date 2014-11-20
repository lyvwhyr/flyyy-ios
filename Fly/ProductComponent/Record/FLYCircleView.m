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

@interface FLYCircleView()

@property (nonatomic) CAShapeLayer *arcLayer;

@end

@implementation FLYCircleView

- (instancetype)initWithCenterPoint:(CGPoint)point radius:(CGFloat)radius color:(UIColor *)color
{
    if (self = [super init]) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:point radius:radius startAngle:0 endAngle:2 * M_PI clockwise:NO];
        _arcLayer = [CAShapeLayer layer];
        _arcLayer.path = path.CGPath;
//        arcLayer.strokeColor = [UIColor flyGreen].CGColor;
        _arcLayer.fillColor = color.CGColor;
//        arcLayer.fillColor = [UIColor whiteColor].CGColor;
        _arcLayer.lineWidth = 5;
        [self.layer addSublayer:_arcLayer];
        
//        [self drawLineAnimation:arcLayer];
    }
    return self;
}

- (void)setupLayerFillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor
{
    _arcLayer.fillColor = fillColor.CGColor;
    _arcLayer.strokeColor = strokeColor.CGColor;
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
