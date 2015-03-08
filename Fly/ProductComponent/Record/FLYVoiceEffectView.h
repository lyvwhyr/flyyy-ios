//
//  FLYVoiceEffectView.h
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLYVoiceFilterEffect) {
    FLYVoiceEffectMe = 0,
    FLYVoiceEffectDisguise
};

@protocol FLYVoiceEffectViewDelegate <NSObject>

- (void)voiceEffectTapped:(FLYVoiceFilterEffect)effect;

@end

@interface FLYVoiceEffectView : UIView

@property (nonatomic) id<FLYVoiceEffectViewDelegate>delegate;

@end
