//
//  FLYVoiceEffectView.m
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYVoiceEffectView.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

@interface FLYVoiceEffectView()

@property (nonatomic) UILabel *voiceEffectTitleLabel;
@property (nonatomic) UIButton *meButton;
@property (nonatomic) UILabel *meLabel;
@property (nonatomic) UIButton *disguseButton;
@property (nonatomic) UILabel *disguseLabel;

@property (nonatomic) FLYVoiceFilterEffect selectedEffect;

@end

@implementation FLYVoiceEffectView

- (instancetype)init
{
    if (self = [super init]) {
        //title
        _voiceEffectTitleLabel = [UILabel new];
        _voiceEffectTitleLabel.font = [UIFont flyFontWithSize:16];
        _voiceEffectTitleLabel.textColor = [UIColor flyBlue];
        _voiceEffectTitleLabel.text = LOC(@"FLYRecordingVoiceEffect");
        [self addSubview:_voiceEffectTitleLabel];
        
        //me button and label
        _meButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_meButton setImage:[UIImage imageNamed:@"icon_record_selected"] forState:UIControlStateNormal];
        [_meButton addTarget:self action:@selector(_meButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_meButton];
        
        _meLabel = [UILabel new];
        _meLabel.font = [UIFont flyFontWithSize:16];
        _meLabel.textColor = [UIColor flyGreen];
        _meLabel.text = LOC(@"FLYRecordingMe");
        [self addSubview:_meLabel];
        
        //disguise button and label
        _disguseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_disguseButton setImage:[UIImage imageNamed:@"icon_record_unselect"] forState:UIControlStateNormal];
        [_disguseButton addTarget:self action:@selector(_disguseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_disguseButton];
        
        _disguseLabel = [UILabel new];
        _disguseLabel.font = [UIFont flyFontWithSize:16];
        _disguseLabel.textColor = [UIColor flyBlue];
        _disguseLabel.text = LOC(@"FLYRecordingDisguise");
        [self addSubview:_disguseLabel];
        
        _selectedEffect = FLYVoiceEffectMe;
    }
    return self;
}

- (void)updateConstraints
{
    [self.voiceEffectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
    }];
    
    [self.meButton sizeToFit];
    CGFloat radius = CGRectGetWidth([self.meButton bounds])/2.0;
    [self.meButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceEffectTitleLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self).offset(-radius - 30);
    }];
    [self.meLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.meButton.mas_bottom).offset(3);
        make.centerX.equalTo(self.meButton);
    }];
    
    [self.disguseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceEffectTitleLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self).offset(radius + 30);
    }];
    [self.disguseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disguseButton.mas_bottom).offset(3);
        make.centerX.equalTo(self.disguseButton);
    }];
    
    [super updateConstraints];
}

#pragma mark - button tap

- (void)_meButtonTapped
{
    if (self.selectedEffect == FLYVoiceEffectMe) {
        return;
    }

    // deselect disguseButton
    [self.disguseButton setImage:[UIImage imageNamed:@"icon_record_unselect"] forState:UIControlStateNormal];
    self.disguseLabel.textColor = [UIColor flyBlue];

    // select me
    self.selectedEffect = FLYVoiceEffectMe;
    [self.meButton setImage:[UIImage imageNamed:@"icon_record_selected"] forState:UIControlStateNormal];
    self.meLabel.textColor = [UIColor flyGreen];
}

- (void)_disguseButtonTapped
{
    if (self.selectedEffect == FLYVoiceEffectDisguise) {
        return;
    }
    
    // deselect disguseButton
    [self.meButton setImage:[UIImage imageNamed:@"icon_record_unselect"] forState:UIControlStateNormal];
    self.meLabel.textColor = [UIColor flyBlue];
    
    // select me
    self.selectedEffect = FLYVoiceEffectDisguise;
    [self.disguseButton setImage:[UIImage imageNamed:@"icon_record_selected"] forState:UIControlStateNormal];
    self.disguseLabel.textColor = [UIColor flyGreen];
}


@end
