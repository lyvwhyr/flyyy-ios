//
//  FLYTabBarView.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTabBarView.h"
#import "FLYTabView.h"
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
    }
    return self;
}

- (void)setTabViews:(NSArray *)tabViews
{
    FLYTabView *tabView = [[FLYTabView alloc] initWithTitle:@"Home" image:@"tabbar_home_active"];
    [self addSubview:tabView];
    
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@1);
        make.left.equalTo(@1);
        make.width.equalTo(@80);
        make.height.equalTo(@44);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"tabBarFrame %@", NSStringFromCGRect(self.frame));
}



@end
