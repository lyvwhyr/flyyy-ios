//
//  FLYEmptyStateView.m
//  Flyy
//
//  Created by Xingxing Xu on 9/7/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYEmptyStateView.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"

#define kImageTopMargin 30
#define kTitleTopMargin 7
#define kDescrptionTopMargin 30
#define kCtaTopMargin 30

@interface FLYEmptyStateView()

@property (nonatomic) UIImageView *bgView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIButton *ctaButton;

@end

@implementation FLYEmptyStateView

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description
{
    if (self = [super init]) {
        _bgView = [UIImageView new];
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        _bgView.image = [UIImage imageNamed:@"bg_empty_state"];
        [self addSubview:_bgView];
        
        _imageView = [UIImageView new];
        _imageView.image = [UIImage imageNamed:@"icon_empty_state_image"];
        [_imageView sizeToFit];
        [self addSubview:_imageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        UIFont *titleFont = [UIFont fontWithName:@"Avenir-Black" size:54.0f];
        NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAttr addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, title.length)];
        [titleAttr addAttributes:@{NSFontAttributeName: titleFont} range:NSMakeRange(0, title.length)];
        [titleAttr addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(0, title.length)];
        _titleLabel.attributedText = titleAttr;
        [self addSubview:_titleLabel];
        
        _descriptionLabel = [UILabel new];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *descriptionAttr = [[NSMutableAttributedString alloc] initWithString:description];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 2;
        [descriptionAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, description.length)];
        [descriptionAttr addAttributes:@{NSFontAttributeName: [UIFont flyFontWithSize:25]} range:NSMakeRange(0, description.length)];
        [descriptionAttr addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(0, description.length)];
        _descriptionLabel.attributedText = descriptionAttr;
        [self addSubview:_descriptionLabel];
        
        _ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _ctaButton.translatesAutoresizingMaskIntoConstraints = NO;
        _ctaButton.layer.cornerRadius = 4.0f;
        [_ctaButton setTitle:@"Join Flyy" forState:UIControlStateNormal];
        [_ctaButton setTitleColor:[FLYUtilities colorWithHexString:@"#9EC5D8"] forState:UIControlStateNormal];
//        [_ctaButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _ctaButton.backgroundColor = [UIColor whiteColor];
        _ctaButton.titleLabel.font = [UIFont flyFontWithSize:21];
//        [_ctaButton sizeToFit];
        [self addSubview:_ctaButton];
        
        [self _addConstrants];
    }
    return self;
}

- (void)_addConstrants
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kImageTopMargin);
        make.centerX.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(kTitleTopMargin);
        make.centerX.equalTo(self);
    }];

    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kDescrptionTopMargin);
        make.leading.greaterThanOrEqualTo(self).offset(36);
        make.trailing.lessThanOrEqualTo(self).offset(-36);
        make.centerX.equalTo(self);
    }];
    
    [self.ctaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(kCtaTopMargin);
        make.centerX.equalTo(self);
        make.width.equalTo(@(290));
        make.height.equalTo(@(42));
    }];
    
}

@end
