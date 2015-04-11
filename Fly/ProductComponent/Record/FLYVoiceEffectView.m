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
#import "FLYFileManager.h"

@interface FLYVoiceEffectView()

@property (nonatomic) UILabel *voiceEffectTitleLabel;
@property (nonatomic) UIButton *meButton;
@property (nonatomic) UILabel *meLabel;
@property (nonatomic) UIButton *disguseButton;
@property (nonatomic) UILabel *disguseLabel;

@property (nonatomic) FLYVoiceFilterEffect selectedEffect;

@property (nonatomic) UISlider *slider;
@property (nonatomic) UILabel *lowLabel;
@property (nonatomic) UILabel *highLabel;

@property (nonatomic) FLYVoiceFilterEffect currentlyProcessingEffect;
@property (nonatomic) NSMutableArray *alreadyProcessedEffects;


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
        _voiceEffectTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_voiceEffectTitleLabel];
        
        _lowLabel = [UILabel new];
        _lowLabel.font = [UIFont flyFontWithSize:13];
        _lowLabel.textColor = [UIColor flyBlue];
        _lowLabel.text = LOC(@"FLYAdjustPitchLow");
        _lowLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_lowLabel];
        
        _highLabel = [UILabel new];
        _highLabel.font = [UIFont flyFontWithSize:13];
        _highLabel.textColor = [UIColor flyBlue];
        _highLabel.text = LOC(@"FLYAdjustPitchHigh");
        _highLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_highLabel];
        
        _slider= [UISlider new];
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *minImage = [UIImage imageNamed:@"icon_slider_line"];
        UIImage *maxImage = [UIImage imageNamed:@"icon_slider_line"];
        UIImage *tumbImage= [UIImage imageNamed:@"icon_slider_touch_selected"];
        [_slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [_slider setThumbImage:tumbImage forState:UIControlStateNormal];
        _slider.continuous = YES;
        [_slider addTarget:self action:@selector(_valueChanged:) forControlEvents:UIControlEventValueChanged];
        _slider.maximumValue = 4;
        _slider.minimumValue = 0;
        _slider.value = 2;
        [self addSubview:_slider];
        
        _currentlyProcessingEffect = FLYVoiceEffectMe;
        _alreadyProcessedEffects = [NSMutableArray new];
        [_alreadyProcessedEffects addObject:@(FLYVoiceEffectMe)];
    }
    return self;
}

- (void)_valueChanged:(UISlider *)sender {
    // round the slider position to the nearest index of the numbers array
    NSUInteger index = (NSUInteger)(_slider.value + 0.5);
    [_slider setValue:index animated:NO];
    if (_currentlyProcessingEffect != index && ![self _isAlreadyProcessed:index]) {
        _currentlyProcessingEffect = index;
        [self.delegate voiceEffectTapped:index];
        [self.alreadyProcessedEffects addObject:@(index)];
    }
    
    if (index != FLYVoiceEffectMe) {
        [FLYAppStateManager sharedInstance].recordingFilePathSelected = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d%@", kRecordingAudioFileNameAfterFilter, (int)index, kAudioFileExt]];
    } else {
        [FLYAppStateManager sharedInstance].recordingFilePathSelected = [[FLYFileManager audioCacheDirectory] stringByAppendingPathComponent:kRecordingAudioFileName];
    }
    
}

- (BOOL)_isAlreadyProcessed:(NSInteger)value
{
    for (int i = 0; i < [self.alreadyProcessedEffects count]; i++) {
        if (value == [self.alreadyProcessedEffects[i] integerValue]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateConstraints
{
    [self.voiceEffectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
    }];
    
    [self.lowLabel sizeToFit];
    [self.lowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.top.equalTo(self.voiceEffectTitleLabel.mas_bottom).offset(40);
        make.width.equalTo(@(CGRectGetWidth(self.lowLabel.bounds)));
    }];
    
    [self.highLabel sizeToFit];
    [self.highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(self.lowLabel);
        make.width.equalTo(@(CGRectGetWidth(self.highLabel.bounds)));
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lowLabel);
        make.leading.equalTo(self.lowLabel.mas_trailing).offset(5);
        make.trailing.equalTo(self.highLabel.mas_leading).offset(-5);
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
    
    [self.delegate voiceEffectTapped:FLYVoiceEffectMe];
}

- (void)_disguseButtonTapped
{
//    if (self.selectedEffect == FLYVoiceEffectDisguise) {
//        return;
//    }
    
    // deselect disguseButton
    [self.meButton setImage:[UIImage imageNamed:@"icon_record_unselect"] forState:UIControlStateNormal];
    self.meLabel.textColor = [UIColor flyBlue];
    
    // select me
//    self.selectedEffect = FLYVoiceEffectDisguise;
    [self.disguseButton setImage:[UIImage imageNamed:@"icon_record_selected"] forState:UIControlStateNormal];
    self.disguseLabel.textColor = [UIColor flyGreen];
    
//    [self.delegate voiceEffectTapped:FLYVoiceEffectDisguise];
}


@end
