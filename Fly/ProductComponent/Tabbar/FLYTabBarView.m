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

#define kTabLeadingMargin        15
#define kTabTopMargin            1
#define kTabWidth                60
#define kTabHeight               44


@interface FLYTabBarView()

@property (nonatomic) UIView *separator;

@end

@implementation FLYTabBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor flyBlue];
        self.userInteractionEnabled = YES;
        
        _separator = [UIView new];
        _separator.translatesAutoresizingMaskIntoConstraints = NO;
        _separator.backgroundColor = [UIColor flyTabBarSeparator];
        [self addSubview:_separator];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setTabViews:(NSArray *)tabViews
{
    _tabViews = tabViews;
    NSInteger count = _tabViews.count;
    for (int i = 0; i < count; i++) {
        FLYTabView *tabView = (FLYTabView *)[_tabViews objectAtIndex:i];
        tabView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:tabView];
        float middleSpacing = ((CGRectGetWidth([UIScreen mainScreen].bounds) - count * kTabWidth - 2 * kTabLeadingMargin))/(count - 1);
        NSInteger leftX = kTabLeadingMargin + i * kTabWidth + i * middleSpacing;
        [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@kTabTopMargin);
                make.leading.equalTo(@(leftX));
                make.width.equalTo(@kTabWidth);
                make.height.equalTo(@kTabHeight);
        }];
    }
}


-(void)updateConstraints
{
    CGFloat height = 1.0/[FLYUtilities FLYMainScreenScale];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0.0);
        make.leading.equalTo(@0.0);
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo([NSNumber numberWithFloat:height]);
    }];
    [super updateConstraints];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] != 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    NSInteger tabIndex = [self _indexOfTabAtPoint:[touch locationInView:self]];
    if (tabIndex != NSNotFound) {
        [self.delegate tabItemClicked:tabIndex];
    }
}

- (NSInteger)_indexOfTabAtPoint:(CGPoint)point
{
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    [self layoutIfNeeded];
    NSInteger tabIndex = NSNotFound;
    for (int i = 0; i < self.tabViews.count; i++) {
        FLYTabView *tabView = (FLYTabView *)[self.tabViews objectAtIndex:i];
        if (CGRectContainsPoint(tabView.frame, point)) {
            tabIndex = i;
            break;
        }
    }
    return tabIndex;
}

@end
