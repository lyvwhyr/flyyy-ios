//
//  FLYCountrySelectorTableViewCell.m
//  Flyy
//
//  Created by Xingxing Xu on 2/28/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYCountrySelectorTableViewCell.h"
#import "UIColor+FLYAddition.h"

#define kLeadingX 10
#define kTrailingX 10

@interface FLYCountrySelectorTableViewCell()

@property (nonatomic) UILabel *countryNameLabel;
@property (nonatomic) UILabel *countryCodeLabel;

@end


@implementation FLYCountrySelectorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _countryNameLabel = [UILabel new];
        _countryNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _countryNameLabel.font = [UIFont fontWithName:@"Avenir-Book" size:15];
        [self.contentView addSubview:_countryNameLabel];
        
        _countryCodeLabel = [UILabel new];
        _countryCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _countryCodeLabel.textColor = [UIColor flyColorFlyCountrySelectorCountryCodeColor];
        _countryCodeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:15];
        [self.contentView addSubview:_countryCodeLabel];
    }
    return self;
}

- (void)configCellWithName:(NSString *)countryName code:(NSString *)code
{
    self.countryNameLabel.text = countryName;
    self.countryCodeLabel.text = code;
}

- (void)updateConstraints
{
    [self.countryNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(kLeadingX);
    }];
    
    [self.countryCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-kTrailingX);
    }];
    
    [super updateConstraints];
}

@end
