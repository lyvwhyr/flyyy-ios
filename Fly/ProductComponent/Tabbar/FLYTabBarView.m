//
//  FLYTabBarView.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTabBarView.h"
#import "UIColor+FLYAddition.h"


@interface FLYTabBarView()

@property (nonatomic) UIView *separator;

@end

@implementation FLYTabBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor flyTabBarBackground];
        self.userInteractionEnabled = YES;
        
        _separator = [UIView new];
        _separator.backgroundColor = [UIColor flyTabBarBackground];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self _addConstraints];
    }
    return self;
}

- (void)_addConstraints
{
    
}



@end
