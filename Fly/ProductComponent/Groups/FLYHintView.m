//
//  FLYHintView.m
//  Flyy
//
//  Created by Xingxing Xu on 8/22/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYHintView.h"
#import "UIFont+FLYAddition.h"
#import "UIColor+FLYAddition.h"

#define kImageTopPadding 18
#define kLabelMargin 20

@interface FLYHintView()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIImageView *imageView;

@end

@implementation FLYHintView

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image
{
    if (self = [super init]) {
        _titleLabel = [UILabel new];
        _titleLabel.text = text;
        _titleLabel.numberOfLines = 0;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 2;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont flyLightFontWithSize:14] range:NSMakeRange(0, text.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[FLYUtilities colorWithHexString:@"#C5C4C4"] range:NSMakeRange(0, text.length)];
        _titleLabel.attributedText = attrStr;
        
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        
        _imageView = [UIImageView new];
        if (image) {
            _imageView.image = image;
        } else {
            _imageView.image = [UIImage imageNamed:@"icon_smile_face"];
        }
        [_imageView sizeToFit];
        [self addSubview:_imageView];
        
        [self _addViewConstraints];
    }
    return self;
}

- (void)_addViewConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.leading.greaterThanOrEqualTo(self).offset(kLabelMargin);
        make.trailing.lessThanOrEqualTo(self).offset(kLabelMargin);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kImageTopPadding);
        make.centerX.equalTo(self);
    }];
}

- (CGSize)intrinsicContentSize
{
    NSString *text = self.titleLabel.text;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 2;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont flyLightFontWithSize:14] range:NSMakeRange(0, text.length)];
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kLabelMargin * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGFloat intrinsicWidth = MIN(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetWidth(self.titleLabel.bounds));
    CGFloat intrinsicHeight = ceilf(rect.size.height) + kImageTopPadding + CGRectGetHeight(self.imageView.bounds);
    return CGSizeMake(intrinsicWidth, intrinsicHeight);
}


@end
