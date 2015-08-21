//
//  FLYSearchBar.m
//  Flyy
//
//  Created by Xingxing Xu on 8/20/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYSearchBar.h"

@interface FLYSearchBar()

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
        _searchIconImageView.image = [UIImage imageNamed:@"icon_search"];
        [_searchIconImageView sizeToFit];
        [self addSubview:_searchIconImageView];
        
        _searchField = [UITextField new];
        _searchField.placeholder = @"Search";
        _searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchField.returnKeyType = UIReturnKeySearch;
        [self addSubview:_searchField];
    }
    return self;
}

- (void)updateConstraints
{
    [self.searchBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.leading.equalTo(self).offset(8);
        make.trailing.equalTo(self).offset(-8);
    }];
    
    [self.searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.width.equalTo(@(CGRectGetWidth(self.searchIconImageView.bounds)));
        make.centerY.equalTo(self);
    }];
    
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(6);
        make.bottom.equalTo(self).offset(-6);
        make.leading.equalTo(self.searchIconImageView.mas_trailing).offset(8);
        make.trailing.equalTo(self).offset(-10);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

@end
