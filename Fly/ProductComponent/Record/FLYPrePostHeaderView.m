//
//  FLYPrePostHeaderView.m
//  Fly
//
//  Created by Xingxing Xu on 2/8/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPrePostHeaderView.h"
#import "Dialog.h"
#import "UIColor+FLYAddition.h"
#import "MJAutoCompleteManager.h"

#define kTopPadding 10
#define kDescriptionTextTopPadding  13
#define kDescpritonHeight   60
#define kMaxCharLengh 120

@interface FLYPrePostHeaderView()<UITextViewDelegate, MJAutoCompleteManagerDataSource, MJAutoCompleteManagerDelegate>

@property (nonatomic) UILabel *captionLabel;
@property (nonatomic) UITextView *descriptionTextView;
@property (nonatomic) UILabel *selectGroupLabel;

@property (nonatomic) MJAutoCompleteManager *autoCompleteMgr;

@end


@implementation FLYPrePostHeaderView

- (instancetype)initWithSearchView:(UIView *)searchView
{
    if (self = [super init]) {
        _captionLabel = [UILabel new];
        [_captionLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        _captionLabel.text = @"Caption:";
        _captionLabel.textColor = [UIColor flyBlue];
        _captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_captionLabel];
        
        _descriptionTextView = [[UITextView alloc] init];
        _descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        [_descriptionTextView setDelegate:self];
        [_descriptionTextView setReturnKeyType:UIReturnKeyDone];
        [_descriptionTextView setText:LOC(@"FLYPrePostDefaultText")];
        [_descriptionTextView setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        [_descriptionTextView setTextColor:[UIColor lightGrayColor]];
        _descriptionTextView.backgroundColor = [UIColor flySettingBackgroundColor];
        [self addSubview:_descriptionTextView];
        
        _selectGroupLabel = [UILabel new];
        [_selectGroupLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:16]];
        _selectGroupLabel.text = @"Popular Tags:";
        _selectGroupLabel.textColor = [UIColor flyBlue];
        _selectGroupLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_selectGroupLabel];
        
        self.autoCompleteMgr = [[MJAutoCompleteManager alloc] init];
        self.autoCompleteMgr.dataSource = self;
        self.autoCompleteMgr.delegate = self;
        
        NSArray *names = @[@"i1", @"i2", @"i3", @"i4", @"i5", @"i6", @"hello"];

        NSArray *items = [MJAutoCompleteItem autoCompleteCellModelFromObjects:names];
        MJAutoCompleteTrigger *hashTrigger = [[MJAutoCompleteTrigger alloc] initWithDelimiter:@"#"
                                                                            autoCompleteItems:items];
        [self.autoCompleteMgr addAutoCompleteTrigger:hashTrigger];
        
        self.autoCompleteMgr.container = searchView;
        
        [self updateConstraintsIfNeeded];
    }
    
    return self;
}

- (void)updateConstraints
{
    [self.captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
    }];
    
    [self.descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captionLabel.mas_bottom).offset(kDescriptionTextTopPadding);
        make.leading.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@kDescpritonHeight);
    }];
    
    [self.selectGroupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionTextView.mas_bottom).offset(kDescriptionTextTopPadding);
        make.leading.equalTo(self);
        make.right.equalTo(self);
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
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        textView.text = LOC(@"FLYPrePostDefaultText");
    }
    
    [_delegate titleTextViewShouldEndEditing:textView];
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self.autoCompleteMgr processString:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(textView.text.length == 0){
            textView.textColor = [UIColor lightGrayColor];
            textView.text = LOC(@"FLYPrePostDefaultText");
            [textView resignFirstResponder];
        }
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    BOOL result = (newLength > kMaxCharLengh) ? NO : YES;
    if (result == NO) {
        [Dialog simpleToast:LOC(@"FLYMaxCaptionLengthExceeded")];
    }
    return result;
}

#pragma mark - MJAutoCompleteMgr DataSource Methods

- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager
         itemListForTrigger:(MJAutoCompleteTrigger *)trigger
                 withString:(NSString *)string
                   callback:(MJAutoCompleteListCallback)callback
{
    /* Since we implemented this method, we are stuck and must handle ALL triggers */
    // the # trigger is trivial:
    static int i = 0;
    i++;
    if ([trigger.delimiter isEqual:@"#"])
    {
        [self.autoCompleteMgr removeAllAutoCompleteTriggers];
        NSMutableArray *names =  [NSMutableArray arrayWithArray: @[@"ai1", @"ai2", @"ai3", @"ai4", @"ai5", @"ai6", [NSString stringWithFormat:@"aii%d", i]]];
        
        NSArray *items = [MJAutoCompleteItem autoCompleteCellModelFromObjects:names];
        MJAutoCompleteTrigger *hashTrigger = [[MJAutoCompleteTrigger alloc] initWithDelimiter:@"#"
                                                                            autoCompleteItems:items];
        [self.autoCompleteMgr addAutoCompleteTrigger:hashTrigger];
        
        
        // we already provided the list
        callback(trigger.autoCompleteItemList);
    }
}

#pragma mark - MJAutoCompleteMgr Delegate methods
- (void)autoCompleteManager:(MJAutoCompleteManager *)acManager shouldUpdateToText:(NSString *)newText
{
    self.descriptionTextView.text = newText;
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
