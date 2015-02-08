//
//  FLYNavigationBar.m
//  Fly
//
//  Created by Xingxing Xu on 12/4/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYNavigationBar.h"
#import "UIColor+FLYAddition.h"

@interface FLYNavigationBar()

@property (nonatomic) UIView *colorView;

@end

@implementation FLYNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor flyBlue], NSFontAttributeName:[UIFont systemFontOfSize:18]};
        self.backgroundColor = [UIColor clearColor];
        self.translucent = YES;
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.colorView) {
        self.colorView = [[UIView alloc] initWithFrame:self.frame];
        self.colorView.backgroundColor = [UIColor flyBlue];
        [self addSubview:self.colorView];
    }
    
    CGFloat aboveBarHeight = MAX(kStatusBarHeight, self.frame.origin.y);
    self.colorView.frame = CGRectMake(0, -aboveBarHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + aboveBarHeight);
    [self insertSubview:self.colorView atIndex:0];
}

- (void)setColor:(UIColor *)color
{
    [self setColor:color];
}

- (void)setColor:(UIColor *)color animated:(BOOL)animated
{
    _color = color ? color : [UIColor flyBlue];
    [UIView animateWithDuration:0 animations:^{
        _colorView.backgroundColor = color;
    }];
}

@end
