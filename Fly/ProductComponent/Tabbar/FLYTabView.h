//
//  FLYTabView.h
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYTabView : UIView

@property (nonatomic) BOOL isRecordTab;

- (instancetype)initWithTitle:(NSString *)title image:(NSString *)imageName recordTab:(BOOL)isRecordTab;

@end
