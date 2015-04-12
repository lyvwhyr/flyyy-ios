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

#define kMeTopPadding 12

@interface FLYVoiceEffectView()

@property (nonatomic) UILabel *voiceEffectTitleLabel;
@property (nonatomic) UILabel *meLabel;

@property (nonatomic) FLYVoiceFilterEffect selectedEffect;

@property (nonatomic) UIImageView *sliderBackgroundView;
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
        
        _meLabel = [UILabel new];
        _meLabel.font = [UIFont flyFontWithSize:11];
        _meLabel.textColor = [UIColor flyBlue];
        _meLabel.text = LOC(@"FLYRecordingMe");
        _meLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_meLabel];
        
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
        
        UIImage *minImage = [UIImage imageNamed:@"icon_record_slider"];
        UIImage *maxImage = [UIImage imageNamed:@"icon_record_slider"];
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
        
        _sliderBackgroundView = [UIImageView new];
        _sliderBackgroundView.image = [UIImage imageNamed:@"slider_template"];
        [self insertSubview:_sliderBackgroundView belowSubview:self.slider];
        
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
    if (_currentlyProcessingEffect != index) {
        _currentlyProcessingEffect = index;
        [self.delegate voiceEffectTapped:index];
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
    
    [self.meLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceEffectTitleLabel);
        make.top.equalTo(self.voiceEffectTitleLabel.mas_bottom).offset(kMeTopPadding);
    }];
    
    [self.lowLabel sizeToFit];
    [self.lowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(10);
        make.top.equalTo(self.meLabel.mas_bottom).offset(20);
        make.width.equalTo(@(CGRectGetWidth(self.lowLabel.bounds)));
    }];
    
    [self.highLabel sizeToFit];
    [self.highLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-10);
        make.top.equalTo(self.lowLabel);
        make.width.equalTo(@(CGRectGetWidth(self.highLabel.bounds)));
    }];
    
    [self.sliderBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lowLabel);
        make.leading.equalTo(self.lowLabel.mas_trailing).offset(10);
        make.trailing.equalTo(self.highLabel.mas_leading).offset(-10);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sliderBackgroundView);
        make.leading.equalTo(self.sliderBackgroundView.mas_leading).offset(5);
        make.trailing.equalTo(self.sliderBackgroundView.mas_trailing).offset(-5);
    }];
    
    [super updateConstraints];
}


@end
