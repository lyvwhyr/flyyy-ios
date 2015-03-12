//
//  FLYAutoPlayControlPanel.m
//  Flyy
//
//  Created by Xingxing Xu on 3/10/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYPlayAllControlPanel.h"
#import "UIColor+FLYAddition.h"

@interface FLYPlayAllControlPanel()

@property (nonatomic) UIButton *playNextButton;
@property (nonatomic) UIButton *pauseButton;
@property (nonatomic) UIButton *playPreviousButton;



@end

@implementation FLYPlayAllControlPanel

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor flyColorPlayAllControlPanelBackground];
        
        _playNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playNextButton setImage:[UIImage imageNamed:@"icon_detail_fastforward"] forState:UIControlStateNormal];
        [self addSubview:_playNextButton];

        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"icon_detail_fastforward"] forState:UIControlStateNormal];
        [self addSubview:_pauseButton];
        
        _playPreviousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPreviousButton setImage:[UIImage imageNamed:@"icon_detail_fastforward"] forState:UIControlStateNormal];
        [self addSubview:_playPreviousButton];
        
    }
    return self;
}

@end
