//
//  FLYPrePostViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostViewController.h"
#import "UIColor+FLYAddition.h"

@interface FLYPrePostViewController ()<UITextViewDelegate>

@property (nonatomic) UIImageView *voiceThumbnailView;
@property (nonatomic) UITextView *descriptionTextView;
@property (nonatomic) UIView *separatorView;

@end

@implementation FLYPrePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _voiceThumbnailView = [UIImageView new];
    _voiceThumbnailView.image = [UIImage imageNamed:@"icon_audio_wave"];
    _voiceThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_voiceThumbnailView];
    
    _descriptionTextView = [[UITextView alloc] init];
    [_descriptionTextView setDelegate:self];
    [_descriptionTextView setReturnKeyType:UIReturnKeyDone];
    [_descriptionTextView setText:@"Add description"];
    [_descriptionTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [_descriptionTextView setTextColor:[UIColor lightGrayColor]];
    [self.view addSubview:_descriptionTextView];
    
    _separatorView = [UIView new];
    _separatorView.backgroundColor = [UIColor flyTabBarSeparator];
    [self.view addSubview:_separatorView];
    
    [self updateViewConstraints];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (_descriptionTextView.textColor == [UIColor lightGrayColor]) {
        _descriptionTextView.text = @"";
        _descriptionTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

- (void)updateViewConstraints
{
    [_voiceThumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.leading.equalTo(self.view).offset(10);
    }];
    
    [_descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.leading.equalTo(self.voiceThumbnailView.mas_right).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@80);
    }];
    
    [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_voiceThumbnailView.mas_bottom).offset(5);
        make.left.equalTo(@0.0);
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)));
        make.height.equalTo(@(1/[FLYUtilities FLYMainScreenScale]));
    }];
    
    [super updateViewConstraints];
    
}



@end
