//
//  FLYRecordVoiceFilterViewController.m
//  Fly
//
//  Created by Xingxing Xu on 12/31/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYRecordVoiceFilterViewController.h"
#import "DKCircleButton.h"
#import "UIColor+FLYAddition.h"

#define kRadius 60

@interface FLYRecordVoiceFilterViewController ()

@property (nonatomic) DKCircleButton *normalButton;
@property (nonatomic) DKCircleButton *adjustPitchButton;

@end

@implementation FLYRecordVoiceFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _normalButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, kRadius, kRadius)];
    _normalButton.center = CGPointMake(40, 40);
    _normalButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _normalButton.borderColor = [UIColor purpleColor];
    [_normalButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    _normalButton.animateTap = NO;
    [_normalButton setTitle:NSLocalizedString(@"Normal", nil) forState:UIControlStateNormal];
    [_normalButton addTarget:self action:@selector(_normalButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_normalButton];
    
    _adjustPitchButton = [[DKCircleButton alloc] initWithFrame:CGRectMake(0, 0, kRadius, kRadius)];
    _adjustPitchButton.borderColor = [UIColor flyGreen];
    _adjustPitchButton.center = CGPointMake(150, 40);
    _adjustPitchButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_adjustPitchButton setTitleColor:[UIColor flyGreen] forState:UIControlStateNormal];
    _adjustPitchButton.animateTap = NO;
    [_adjustPitchButton setTitle:NSLocalizedString(@"Adjust Pitch", nil) forState:UIControlStateNormal];
    [_adjustPitchButton addTarget:self action:@selector(_adjustPitchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_adjustPitchButton];
    
}

- (void)_normalButtonTapped:(id)sender
{
    [self.delegate normalFilterButtonTapped:sender];
}

- (void)_adjustPitchButtonTapped:(id)sender
{
    [self.delegate adjustPitchFilterButtonTapped:sender];
}

@end
