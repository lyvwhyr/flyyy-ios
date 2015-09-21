//
//  FLYSearchBar.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSearchBar.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

@interface FLYSearchBar() <UITextFieldDelegate>

@property (nonatomic) UIView *searchBackgroundView;
@property (nonatomic) UITextField *searchField;
@property (nonatomic) UIImageView *searchIconImageView;
@property (nonatomic) UIButton *cancelButton;

@end

@implementation FLYSearchBar

- (instancetype)init
{
    if (self = [super init]) {
        _searchBackgroundView = [UIView new];
        _searchBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBackgroundView.backgroundColor = [FLYUtilities colorWithHexString:@"#7E9099" alpha:0.14f];
        _searchBackgroundView.layer.cornerRadius = 4.0f;
        [self addSubview:_searchBackgroundView];
        
        _searchIconImageView = [UIImageView new];
        _searchBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _searchIconImageView.image = [UIImage imageNamed:@"icon_search"];
        [_searchIconImageView sizeToFit];
        [self addSubview:_searchIconImageView];
        
        _searchField = [UITextField new];
        _searchField.translatesAutoresizingMaskIntoConstraints = NO;
        _searchField.placeholder = @"Search";
        _searchField.font = [UIFont flyFontWithSize:15];
        _searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.delegate = self;
        [self addSubview:_searchField];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton addTarget:self action:@selector(_cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:LOC(@"FLYButtonCancelText") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor flyColorFlyGreyText] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont flyFontWithSize:16];
        [_cancelButton sizeToFit];
        [self addSubview:_cancelButton];
        _cancelButton.hidden = YES;
    }
    return self;
}

- (void)updateConstraints
{
    [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.width.equalTo(@(CGRectGetWidth(self.searchIconImageView.bounds)));
        make.centerY.equalTo(self);
    }];
    
    if (self.cancelButton.hidden) {
        [self.searchBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.leading.equalTo(self).offset(8);
            make.trailing.equalTo(self).offset(-8);
        }];
        
        [self.searchField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.bottom.equalTo(self).offset(-6);
            make.leading.equalTo(self.searchIconImageView.mas_trailing).offset(8);
            make.trailing.equalTo(self).offset(-10);
        }];
    } else {
        [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self).offset(-10);
            make.width.equalTo(@(CGRectGetWidth(self.cancelButton.bounds)));
        }];
        
        [self.searchBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.leading.equalTo(self).offset(8);
            make.trailing.equalTo(self.cancelButton.mas_leading).offset(-10);
        }];
        
        [self.searchField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.bottom.equalTo(self).offset(-6);
            make.leading.equalTo(self.searchIconImageView.mas_trailing).offset(8);
            make.trailing.equalTo(self.cancelButton.mas_leading).offset(-10);
        }];
    }
    
    [super updateConstraints];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _cancelButton.hidden = NO;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self.delegate searchBarDidBeginEditing:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        newText = [newText stringByReplacingOccurrencesOfString:@" " withString:@""];
        [self.delegate searchBar:self textDidChange:newText];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    return YES;
}


- (void)_cancelButtonTapped
{
    [self.searchField resignFirstResponder];
    self.searchField.text = @"";
    
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.cancelButton.hidden = YES;
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
}

//- (void)layoutSubviews
//{
//    [self setNeedsUpdateConstraints];
//    [self updateConstraintsIfNeeded];
//    [super layoutSubviews];
//}

@end
