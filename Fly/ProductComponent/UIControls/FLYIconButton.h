//
//  FLYIconButton.h
//  Fly
//
//  Created by Xingxing Xu on 11/28/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYIconButton : UIButton

@property (nonatomic) CGFloat overrideIconRightPadding;

- (instancetype)initWithText:(NSString *)text textFont:(UIFont *)font textColor:(UIColor *)color icon:(NSString *)iconName isIconLeft:(BOOL)isIconLeft;
- (void)setLabelText:(NSString *)text;

@end
