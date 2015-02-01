//
//  FLYIconButton.h
//  Fly
//
//  Created by Xingxing Xu on 11/28/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYIconButton : UIButton

- (instancetype)initWithText:(NSString *)text textFont:(UIFont *)font textColor:(UIColor *)color icon:(NSString *)iconName;
- (void)setLabelText:(NSString *)text;

@end
