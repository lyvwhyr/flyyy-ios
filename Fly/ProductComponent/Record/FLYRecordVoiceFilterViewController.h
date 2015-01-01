//
//  FLYRecordVoiceFilterViewController.h
//  Fly
//
//  Created by Xingxing Xu on 12/31/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"

@class DKCircleButton;

@protocol FLYUniversalViewControllerDelegate <NSObject>

- (void)normalFilterButtonTapped:(id)button;
- (void)adjustPitchFilterButtonTapped:(id)button;

@end

@interface FLYRecordVoiceFilterViewController : FLYUniversalViewController

@property (nonatomic, weak)id<FLYUniversalViewControllerDelegate> delegate;

@end
