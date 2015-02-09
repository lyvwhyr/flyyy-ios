//
//  FLYPrePostHeaderView.h
//  Fly
//
//  Created by Xingxing Xu on 2/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLYPrePostHeaderViewDelegate <NSObject>

- (BOOL)titleTextViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)titleTextViewShouldEndEditing:(UIView *)textView;

@end

@interface FLYPrePostHeaderView : UIView

@property (nonatomic, weak) id<FLYPrePostHeaderViewDelegate> delegate;

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

@end
