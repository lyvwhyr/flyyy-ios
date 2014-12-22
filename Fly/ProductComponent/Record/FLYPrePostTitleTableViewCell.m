//
//  FLYPrePostTitleTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 12/11/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostTitleTableViewCell.h"

#define kTopPadding 10

@interface FLYPrePostTitleTableViewCell()<UITextViewDelegate>

@property (nonatomic) UIImageView *voiceThumbnailView;
@property (nonatomic) UITextView *descriptionTextView;

@end

@implementation FLYPrePostTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _voiceThumbnailView = [UIImageView new];
        _voiceThumbnailView.image = [UIImage imageNamed:@"icon_audio_wave"];
        _voiceThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self addSubview:_voiceThumbnailView];
        
        _descriptionTextView = [[UITextView alloc] init];
        [_descriptionTextView setDelegate:self];
        [_descriptionTextView setReturnKeyType:UIReturnKeyDone];
        [_descriptionTextView setText:@"Add description"];
        [_descriptionTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        [_descriptionTextView setTextColor:[UIColor lightGrayColor]];
        [self addSubview:_descriptionTextView];
        
        [self updateConstraintsIfNeeded];
    }
    
    return self;
}

- (void)updateConstraints
{
//    [_voiceThumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(kTopPadding);
//        make.leading.equalTo(self).offset(10);
//    }];
    
    [_descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTopPadding);
        make.leading.equalTo(self).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.height.equalTo(@60);
    }];
    [super updateConstraints];
}

#pragma mark - UITextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [_delegate titleTextViewShouldBeginEditing:textView];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [_delegate titleTextViewShouldEndEditing:textView];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        textView.text = @"List words or terms separated by commas";
        [textView resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(textView.text.length == 0){
            textView.textColor = [UIColor lightGrayColor];
            textView.text = @"List words or terms separated by commas";
            [textView resignFirstResponder];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - UIResponder
- (void)becomeFirstResponder
{
    [_descriptionTextView becomeFirstResponder];
}

- (void)resignFirstResponder
{
    [_descriptionTextView resignFirstResponder];
}



@end
