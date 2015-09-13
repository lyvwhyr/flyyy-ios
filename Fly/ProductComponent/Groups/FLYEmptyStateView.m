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
#import "SDiPhoneVersion.h"

#define kTitleTopMargin 45
#define kDescrptionTopMargin 30
#define kCtaTopMargin 30

@interface FLYEmptyStateView()

@property (nonatomic) UIImageView *bgView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIButton *ctaButton;

@property (nonatomic, copy) FLYEmptyStateViewActionBlock actionBlock;

@end

@implementation FLYEmptyStateView

- (instancetype)initWithTitle:(NSString *)title description:(NSString *)description actionBlock:(FLYEmptyStateViewActionBlock)actionBlock
{
    if (self = [super init]) {
        _actionBlock = [actionBlock copy];
        
        _bgView = [UIImageView new];
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        _bgView.image = [UIImage imageNamed:@"bg_empty_state"];
        [self addSubview:_bgView];
        
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
        _ctaButton.backgroundColor = [UIColor whiteColor];
        _ctaButton.titleLabel.font = [UIFont flyFontWithSize:21];
        [_ctaButton addTarget:self action:@selector(_ctaTapped) forControlEvents:UIControlEventTouchUpInside];
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
    
    
    CGFloat titleTop = kTitleTopMargin;
    DeviceVersion deviceVersion = [SDiPhoneVersion deviceVersion];
    if (deviceVersion == iPhone6Plus) {
        titleTop = 120;
    } else if (deviceVersion == iPhone6) {
        titleTop = 70;
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(titleTop);
        make.centerX.equalTo(self);
    }];

    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kDescrptionTopMargin);
        make.leading.greaterThanOrEqualTo(self).offset(30);
        make.trailing.lessThanOrEqualTo(self).offset(-30);
        make.centerX.equalTo(self);
    }];
    
    [self.ctaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(kCtaTopMargin);
        make.centerX.equalTo(self);
        make.width.equalTo(@(290));
        make.height.equalTo(@(42));
    }];
    
}

- (void)_ctaTapped
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

@end
