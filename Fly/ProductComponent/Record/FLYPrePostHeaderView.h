//
//  FLYPrePostHeaderView.h
//  Fly
//
//  Created by Xingxing Xu on 2/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYPrePostHeaderView;

@protocol FLYPrePostHeaderViewDelegate <NSObject>

- (BOOL)titleTextViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)titleTextViewShouldEndEditing:(UIView *)textView;
- (void)searchViewWillAppear:(FLYPrePostHeaderView *)view;
- (void)searchViewWillDisappear:(FLYPrePostHeaderView *)view;


@end

@interface FLYPrePostHeaderView : UIView

@property (nonatomic) UITextView *descriptionTextView;
@property (nonatomic, weak) id<FLYPrePostHeaderViewDelegate> delegate;

- (instancetype)initWithSearchView:(UIView *)searchView;
- (void)becomeFirstResponder;
- (void)resignFirstResponder;
- (void)addTagWithTagName:(NSString *)tagName;

@end
