//
//  FLYInlineActionView.h
//  Fly
//
//  Created by Xingxing Xu on 11/29/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FLYCommentButtonTappedBlock)();

@interface FLYInlineActionView : UIView

@property (nonatomic, copy) FLYCommentButtonTappedBlock commentButtonTappedBlock;

@end
