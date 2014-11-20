//
//  FLYRecordViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/17/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYRecordViewController.h"
#import "FLYCircleView.h"
#import "UIColor+FLYAddition.h"
#import "SVPulsingAnnotationView.h"
#import "PulsingHaloLayer.h"
#import "MultiplePulsingHaloLayer.h"

#define kInnerCircleRadius 100

@interface FLYRecordViewController ()

@property (nonatomic) FLYCircleView *circleView;
@property (nonatomic) UIImageView *centerImageView;
@property (nonatomic) UILabel *recordedTimeLabel;
@property (nonatomic) SVPulsingAnnotationView *pulsingView;
@property (nonatomic, weak) PulsingHaloLayer *halo;

@property (nonatomic) NSInteger recordedSeconds;

@end

@implementation FLYRecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _recordedSeconds = 0;
    
    [self _addSubviews];
    
    [self updateViewConstraints];
}


#pragma mark - add subviews
- (void)_addSubviews
{
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    self.halo = layer;
    self.halo.radius = 150;
    [self.view.layer insertSublayer:self.halo below:self.centerImageView.layer];
    
    _circleView = [[FLYCircleView alloc] initWithCenterPoint:CGPointMake(kInnerCircleRadius, kInnerCircleRadius)];
    [self.view addSubview:_circleView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _centerImageView = [UIImageView new];
    _centerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_centerImageView setImage:[UIImage imageNamed:@"icon_voice_record"]];
    [self.view addSubview:_centerImageView];
    
    _recordedTimeLabel = [UILabel new];
    _recordedTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _recordedTimeLabel.textColor = [UIColor flyGreen];
    _recordedTimeLabel.text = @"0 s";
    [self.view addSubview:_recordedTimeLabel];
}

-(void)updateViewConstraints
{
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@0);
        make.top.equalTo(@(0));
        make.width.equalTo(@(kMainScreenWidth));
        make.height.equalTo(@(kContainerViewHeight + kTabBarViewHeight));
    }];
    
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kInnerCircleRadius * 2));
        make.height.equalTo(@(kInnerCircleRadius * 2));
        make.center.equalTo(self.view);
    }];
    
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.circleView);
    }];
    
    [self.recordedTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.circleView.mas_top).with.offset(-20);
        make.centerX.equalTo(self.circleView.mas_centerX);
    }];
    
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.halo.position = self.centerImageView.center;
}

@end
