//
//  FLYPrePostTitleTableViewCell.h
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

@protocol FLYPrePostTitleTableViewCellDelegate <NSObject>

- (BOOL)titleTextViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)titleTextViewShouldEndEditing:(UIView *)textView;

@end


@interface FLYPrePostTitleTableViewCell : UITableViewCell

@property (nonatomic, weak) id<FLYPrePostTitleTableViewCellDelegate> delegate;

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

@end
