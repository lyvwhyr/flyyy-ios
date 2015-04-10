//
//  FLYDashTextView.h
//  Flyy
//
//  Created by Xingxing Xu on 4/9/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

typedef NS_ENUM(NSInteger, FLYDashTextColor) {
    FLYDashTextWhite = 0,
    FLYDashTextBlue
};


@interface FLYDashTextView : UIView

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color hightlightItems:(NSArray *)highlightItems highlightFont:(UIFont *)highlightFont edgeInsets:(UIEdgeInsets)edgeInsets dashColor:(FLYDashTextColor)dashColor maxLabelWidth:(CGFloat)width;

+ (CGFloat)geLabelHeightWithText:(NSString *)text font:(UIFont *)font hightlightItems:(NSArray *)highlightItems highlightFont:(UIFont *)highlightFont maxLabelWidth:(CGFloat)width;

@end
