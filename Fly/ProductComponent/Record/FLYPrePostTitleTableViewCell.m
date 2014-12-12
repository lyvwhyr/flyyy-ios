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


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (_descriptionTextView.textColor == [UIColor lightGrayColor]) {
        _descriptionTextView.text = @"";
        _descriptionTextView.textColor = [UIColor blackColor];
    }
    return YES;
}



@end
