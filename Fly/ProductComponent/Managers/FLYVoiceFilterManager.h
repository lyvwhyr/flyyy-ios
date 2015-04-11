//
//  FLYVoiceFilterManager.h
//  Flyy
//
//  Created by Xingxing Xu on 3/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYVoiceEffectView.h"

@interface FLYVoiceFilterManager : NSObject

@property (nonatomic) FLYVoiceFilterEffect effect;

- (instancetype)initWithEffect:(FLYVoiceFilterEffect)effect;
- (void)applyFiltering:(FLYVoiceFilterEffect)voiceFilter;

@end
