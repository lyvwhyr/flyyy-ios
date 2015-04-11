//
//  FLYVoiceEffectView.h
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//


typedef NS_ENUM(NSInteger, FLYVoiceFilterEffect) {
    FLYVoiceEffectLow1 = 0,
    FLYVoiceEffectLow2,
    FLYVoiceEffectMe,
    FLYVoiceEffectHigh1,
    FLYVoiceEffectHigh2
};

@protocol FLYVoiceEffectViewDelegate <NSObject>

- (void)voiceEffectTapped:(FLYVoiceFilterEffect)effect;

@end

@interface FLYVoiceEffectView:UIView

@property (nonatomic) id<FLYVoiceEffectViewDelegate>delegate;

@end
