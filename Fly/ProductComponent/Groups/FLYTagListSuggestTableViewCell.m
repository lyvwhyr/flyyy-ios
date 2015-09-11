//
//  FLYGroupListSuggestTableViewCell.m
//  Fly
//
//  Created by Xingxing Xu on 11/30/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTagListSuggestTableViewCell.h"

@interface FLYTagListSuggestTableViewCell()

@property (nonatomic) UIImageView *suggestImageView;
@property (nonatomic) UILabel *suggestTextLabel;

@end

@implementation FLYTagListSuggestTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _suggestImageView = [UIImageView new];
        [_suggestImageView setImage:[UIImage imageNamed:@"icon_suggest_group"]];
        [self addSubview:_suggestImageView];
        
        _suggestTextLabel = [UILabel new];
        _suggestTextLabel.text = @"Suggest a tag";
        [self addSubview:_suggestTextLabel];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    [_suggestImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(20);
    }];
    
    [_suggestTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(_suggestImageView.mas_right).offset(10);
    }];
    
    [super updateConstraints];
}

@end
