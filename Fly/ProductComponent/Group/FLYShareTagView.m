//
//  FLYShareTagView.m
//  Flyy
//
//  Created by Xingxing Xu on 9/20/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYShareTagView.h"

#define kShareIconLeftMargin 5

@interface FLYShareTagView()

@property (nonatomic) UILabel *tagLabel;
@property (nonatomic) UIImageView *shareImageView;

@end

@implementation FLYShareTagView

- (instancetype)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        _tagLabel = [UILabel new];
        UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:title];
        [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont} range:NSMakeRange(0, title.length)];
        _tagLabel.attributedText = attributedStr;
        [self addSubview:_tagLabel];
        
        _shareImageView = [UIImageView new];
        _shareImageView.image = [UIImage imageNamed:@"icon_tag_share"];
        [_shareImageView sizeToFit];
        [self addSubview:_shareImageView];
        
        [self _addConstraints];
    }
    return self;
}

- (void)_addConstraints
{
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.centerY.equalTo(self);
        
    }];
    
    [self.shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tagLabel.mas_trailing).offset(kShareIconLeftMargin);
        make.centerY.equalTo(self);
    }];
}

+ (CGSize)viewSize:(NSString *)title
{
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Book" size:16];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont} range:NSMakeRange(0, title.length)];
    CGRect labelRect = [attributedStr boundingRectWithSize:CGSizeMake(300, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat labelWidth = labelRect.size.width;
    
    UIImageView *shareImageView = [UIImageView new];
    shareImageView.image = [UIImage imageNamed:@"icon_tag_share"];
    [shareImageView sizeToFit];
    CGFloat imageWidth = CGRectGetWidth(shareImageView.bounds);
    
    return CGSizeMake(labelWidth + kShareIconLeftMargin + imageWidth, 30);
}

@end
