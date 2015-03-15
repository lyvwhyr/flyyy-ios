//
//  FLYTabView.m
//  Fly
//
//  Created by Xingxing Xu on 11/16/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYTabView.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"

#define kLabelPosV      28
#define kImagePosV      1

@interface FLYTabView()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *label;

@end

@implementation FLYTabView

- (instancetype)initWithTitle:(NSString *)title image:(NSString *)imageName recordTab:(BOOL)isRecordTab
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (!isRecordTab) {
            _imageView = [UIImageView new];
            _imageView.translatesAutoresizingMaskIntoConstraints = NO;
            UIImage *image = [UIImage imageNamed:imageName];
            [_imageView setImage:image];
            [self addSubview:_imageView];
            
//            _label = [UILabel new];
//            _label.translatesAutoresizingMaskIntoConstraints = NO;
//            _label.font = [UIFont flyToolBarFont];
//            _label.textColor = [UIColor flyBlue];
//            _label.text = title;
//            [self addSubview:_label];
        } else {
            _imageView = [UIImageView new];
            _imageView.translatesAutoresizingMaskIntoConstraints = NO;
            UIImage *image = [UIImage imageNamed:imageName];
            [_imageView setImage:image];
            [self addSubview:_imageView];
        }
        _isRecordTab = isRecordTab;
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setTabImage:(UIImage *)image
{
    _imageView.image = image;
}

- (void)updateConstraints
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];
    
//    NSDictionary *metrics = @{@"imagePosV":@(kImagePosV), @"labelPosV":@(kLabelPosV)};
//    
//    NSArray *imagePosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-imagePosV-[_imageView]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_imageView)];
//    [self addConstraints:imagePosV];
//    
//    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//    }];

    //label constraints
//    if (!self.isRecordTab) {
//        NSArray *labelPosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-labelPosV-[_label]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_label)];
//        [self addConstraints:labelPosV];
//        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self);
//        }];
//    }
    [super updateConstraints];
}

@end
