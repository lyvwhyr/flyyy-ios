//
//  FLYDashTextView.m
//  Flyy
//
//  Created by Xingxing Xu on 4/9/15.
//  Copyright (c) 2015 Fly. All rights reserved.
//

#import "FLYDashTextView.h"
#import "NIAttributedLabel.h"

@interface FLYDashTextView()

@property (nonatomic) NIAttributedLabel *textLabel;
@property (nonatomic) UIImageView *dashBox;

@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) CGFloat maxWidth;

@property (nonatomic) UIFont *font;
@property (nonatomic) UIFont *highlightFont;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic) NSArray *highlightItems;

@end


@implementation FLYDashTextView

- (instancetype)initWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color hightlightItems:(NSArray *)highlightItems highlightFont:(UIFont *)highlightFont edgeInsets:(UIEdgeInsets)edgeInsets dashColor:(FLYDashTextColor)dashColor maxLabelWidth:(CGFloat)width
{
    if (self = [super init]) {
        _maxWidth = width;
        _font = font;
        _highlightFont = highlightFont;
        _labelText = text;
        _highlightItems = highlightItems;
        
        _dashBox = [UIImageView new];
        UIImage *originalImage;
        if (dashColor == FLYDashTextWhite) {
            originalImage = [UIImage imageNamed:@"icon_dashed_box_white"];
        } else if (dashColor == FLYDashTextBlue) {
            originalImage = [UIImage imageNamed:@"icon_dashed_box_blue"];
        }
        UIEdgeInsets insets = UIEdgeInsetsMake(3, 3, 3, 3);
        UIImage *boxImage = [originalImage resizableImageWithCapInsets:insets];
        self.dashBox.image = boxImage;
        [self addSubview:_dashBox];
        
        _textLabel = [NIAttributedLabel new];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _edgeInsets = edgeInsets;
        _textLabel.font = font;
        _textLabel.textColor = color;
        _textLabel.text = text;
        if (highlightItems) {
            for (int i = 0; i < [highlightItems count]; i++) {
                [_textLabel setFont:highlightFont range:[_textLabel.text rangeOfString:highlightItems[i]]];
            }
        }
        [self addSubview:_textLabel];
    }
    
    return self;
}

+ (CGFloat)geLabelHeightWithText:(NSString *)text font:(UIFont *)font hightlightItems:(NSArray *)highlightItems highlightFont:(UIFont *)highlightFont maxLabelWidth:(CGFloat)width
{
    NIAttributedLabel *textLabel = [NIAttributedLabel new];
    textLabel.numberOfLines = 0;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = font;
    textLabel.text = text;
    if (highlightItems) {
        for (int i = 0; i < [highlightItems count]; i++) {
            [textLabel setFont:highlightFont range:[textLabel.text rangeOfString:highlightItems[i]]];
        }
    }
    NSAttributedString *attributedStr = textLabel.attributedText;
    CGRect rect = [attributedStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return ceilf(rect.size.height);
}

- (void)updateConstraints
{
    CGFloat textHeight = [FLYDashTextView geLabelHeightWithText:self.labelText font:self.font hightlightItems:self.highlightItems highlightFont:self.highlightFont maxLabelWidth:self.maxWidth];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(self.edgeInsets.top);
        make.width.equalTo(@(self.maxWidth));
        make.height.equalTo(@(textHeight));
    }];
    
    [self.dashBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.with.insets(UIEdgeInsetsZero);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateConstraints];
}


@end
