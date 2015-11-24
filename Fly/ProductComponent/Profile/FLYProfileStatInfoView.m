//
//  FLYProfileStatInfoView.m
//  Flyy
//
//  Created by Xingxing Xu on 11/5/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYProfileStatInfoView.h"
#import "UIFont+FLYAddition.h"

@interface FLYProfileStatInfoView()

@property (nonatomic) UILabel *firstLineLabel;
@property (nonatomic) UILabel *secondLineLabel;

@end

@implementation FLYProfileStatInfoView

- (instancetype)initWithCount:(NSInteger)count name:(NSString *)name
{
    if (self = [super init]) {
        _firstLineLabel = [UILabel new];
        _firstLineLabel.text = [@(count) stringValue];
        _firstLineLabel.font = [UIFont flyFontWithSize:22.0f];
        _firstLineLabel.textColor = [UIColor whiteColor];
        [_firstLineLabel sizeToFit];
        [self addSubview:_firstLineLabel];
        
        _secondLineLabel = [UILabel new];
        _secondLineLabel.text = name;
        _secondLineLabel.textColor = [UIColor whiteColor];
        _secondLineLabel.font = [UIFont flyFontWithSize:10.0f];
        [_secondLineLabel sizeToFit];
        [self addSubview:_secondLineLabel];
    }
    return self;
}

- (void)setCount:(NSInteger)count
{
    _firstLineLabel.text = [@(count) stringValue];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    [self.firstLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    [self.secondLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.firstLineLabel.mas_bottom).offset(6);
        make.centerX.equalTo(self);
    }];
    
    [super updateConstraints];
}

@end
