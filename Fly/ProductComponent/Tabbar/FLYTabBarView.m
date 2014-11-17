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

#define kTabLeadingMargin        20
#define kTabTopMargin            1
#define kTabWidth                80
#define kTabHeight               44


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
    _tabViews = tabViews;
    NSInteger count = _tabViews.count;
    for (int i = 0; i < count; i++) {
        FLYTabView *tabView = (FLYTabView *)[_tabViews objectAtIndex:i];
        [self addSubview:tabView];
        float middleSpacing = ((CGRectGetWidth([UIScreen mainScreen].bounds) - count * kTabWidth - 2 * kTabLeadingMargin))/(count - 1);
        NSInteger leftX = kTabLeadingMargin + i * kTabWidth + i * middleSpacing;
        [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@kTabTopMargin);
                make.left.equalTo(@(leftX));
                make.width.equalTo(@kTabWidth);
                make.height.equalTo(@kTabHeight);
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"tabBarFrame %@", NSStringFromCGRect(self.frame));
}



@end
