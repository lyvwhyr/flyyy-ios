//
//  FLYSignupFollowTagsViewController.m
//  Flyy
//
//  Created by Xingxing Xu on 9/13/15.
//  Copyright © 2015 Fly. All rights reserved.
//

#import "FLYSignupFollowTagsViewController.h"
#import "UIColor+FLYAddition.h"
#import "UIFont+FLYAddition.h"
#import "FLYGroup.h"
#import "FLYGroupManager.h"
#import "FLYTagsService.h"
#import "Dialog.h"
#import "FLYTagsManager.h"

#define kLeftPadding    15.0f
#define kTagButtonHorizontalSpacing 19.0f
#define kTagButtonVerticalSpacing 12.0f

@interface FLYSignupFollowTagsViewController ()

@property (nonatomic) UIImageView *topBgImage;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *contentView;

@property (nonatomic) NSArray *groups;
@property (nonatomic) NSMutableArray *tagButtonArray;
@property (nonatomic) BOOL alreadyLayouted;
@property (nonatomic) UIButton *lastButton;

@property (nonatomic) NSUInteger followTagCount;
@property (nonatomic) NSMutableArray *followedTags;

@end

@implementation FLYSignupFollowTagsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.followedTags = [NSMutableArray new];
    self.groups = [NSArray arrayWithArray:[FLYGroupManager sharedInstance].groupList];
    
    self.title = @"Follow Tags";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topBgImage = [UIImageView new];
    self.topBgImage.image = [UIImage imageNamed:@"icon_follow_multiple_tags"];
    [self.topBgImage sizeToFit];
    [self.view addSubview:self.topBgImage];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor flyBlue];
    [self.doneButton addTarget:self action:@selector(_doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
    
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];
    self.scrollView.scrollEnabled = YES;
    
    _tagButtonArray = [NSMutableArray new];
    [self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FLYGroup *group = (FLYGroup *)obj;
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tagButton.layer.cornerRadius = 4.0f;
        tagButton.layer.borderColor = [UIColor flyShareTextGrey].CGColor;
        tagButton.layer.borderWidth = 1.0f;
        tagButton.tag = idx;
        tagButton.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
        tagButton.titleLabel.font = [UIFont flyFontWithSize:14.0f];
        [tagButton setTitleColor:[FLYUtilities colorWithHexString:@"#737373"] forState:UIControlStateNormal];
        [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [tagButton addTarget:self action:@selector(_tagSelected:) forControlEvents:UIControlEventTouchUpInside];
        [tagButton setTitle:group.groupName forState:UIControlStateNormal];
        [tagButton sizeToFit];
        [self.contentView addSubview:tagButton];
        [self.tagButtonArray addObject:tagButton];
    }];
    
    [self addConstraint];
}

- (void)addConstraint
{
    [self.topBgImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.equalTo(@(49));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImage.mas_bottom).offset(15);
        make.bottom.equalTo(self.doneButton.mas_top);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.height.equalTo(@(700));
    }];
    
    // tag buttons
    UIButton *previousButton;
    CGFloat currentWidth = 0.0;
    CGFloat MAX_ROW_WIDTH = CGRectGetWidth(self.view.bounds) - kLeftPadding;
    NSMutableArray *buttonsInRow = [NSMutableArray new];
    for (UIButton *currentButton in self.tagButtonArray) {
        CGFloat buttonWidth = CGRectGetWidth(currentButton.bounds);
        if ((buttonWidth + currentWidth) < MAX_ROW_WIDTH) {
            if (previousButton == nil) {
                [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.contentView);
                    make.leading.equalTo(self.contentView).offset(kLeftPadding);
                }];
            } else {
                [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(previousButton);
                    make.leading.equalTo(previousButton.mas_trailing).offset(kTagButtonHorizontalSpacing);
                }];
            }
            [buttonsInRow addObject:currentButton];
        } else {
            if (!self.alreadyLayouted) {
                NSInteger buttonCountInRow = [buttonsInRow count];
                CGFloat bWidth = 0.0f;
                for (UIButton *button in buttonsInRow) {
                    bWidth += CGRectGetWidth(button.bounds);
                }
                CGFloat hSpacing = (MAX_ROW_WIDTH - bWidth - kTagButtonHorizontalSpacing * (buttonCountInRow - 1))/(CGFloat)buttonCountInRow/2.0f - 1;
                for (int i = 0; i < buttonsInRow.count; i++) {
                    UIButton *btn = buttonsInRow[i];
                    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
                    btn.contentEdgeInsets = UIEdgeInsetsMake(5, 15 + hSpacing, 5, 15 + hSpacing);
                    [btn sizeToFit];
                }
                [buttonsInRow removeAllObjects];
                
                [buttonsInRow addObject:currentButton];
            }
            // new line
            currentWidth = 0.0f;
            [currentButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView).offset(kLeftPadding);
                make.top.equalTo(previousButton.mas_bottom).offset(kTagButtonVerticalSpacing);
            }];
        }
        currentWidth += buttonWidth + kTagButtonHorizontalSpacing;
        previousButton = currentButton;
        self.lastButton = currentButton;
    }
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.bottom.equalTo(self.lastButton.mas_bottom).offset(30);
    }];
}

- (void)loadLeftBarButton
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMaxY(self.lastButton.frame) + 30);
}

- (void)_tagSelected:(UIButton *)button
{
    button.selected = !button.selected;
    FLYGroup *tag = self.groups[button.tag];
    if (button.selected) {
        // follow tags
        [button setBackgroundColor:[UIColor flyBlue]];
        button.layer.borderColor = [UIColor flyBlue].CGColor;
        
        self.followTagCount++;
        [self.followedTags addObject:tag];
        
        [FLYTagsService followTagWithId:tag.groupId followed:NO successBlock:nil errorBlock:nil];
    } else {
        // unfollow tags
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.borderColor = [UIColor flyShareTextGrey].CGColor;
        [FLYTagsService followTagWithId:tag.groupId followed:YES successBlock:nil errorBlock:nil];
        [self.followedTags removeObject:tag];
        self.followTagCount--;
    }
}

- (void)_doneButtonTapped
{
    if (self.followTagCount <= 2) {
        [Dialog simpleToast:LOC(@"FLYSignupFollowAtLeastThreeTags")];
        return;
    }
    if (self.followedTags.count > 0) {
        [[FLYTagsManager sharedInstance] updateCurrentUserTags:self.followedTags];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSuccessfulLoginNotification object:self];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation bar and status bar
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}

@end
