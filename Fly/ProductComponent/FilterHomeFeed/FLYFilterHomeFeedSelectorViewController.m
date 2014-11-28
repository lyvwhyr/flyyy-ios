//
//  FLYFilterHomeFeedSelectorViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/27/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYFilterHomeFeedSelectorViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYFilterSelectorGroupTableViewCell.h"

#define EXPLANATION_TEXT_LINE_SPACING          8.0f
#define EXPLANATION_TEXT_TOP_PADDING           10.0f
#define EXPLANATION_TEXT_FONT_SIZE             22.0f
#define FILTER_VIEW_LEFT_PADDING               20.0f

@interface FLYFilterHomeFeedSelectorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UIView *explanationView;
@property (nonatomic) UILabel *explanationLabel;
@property (nonatomic) UITableView *groupsTabelView;

@property (nonatomic) NSMutableArray *groups;

@end

@implementation FLYFilterHomeFeedSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Filter";
    [self _setupNavigationBar];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _explanationLabel = [UILabel new];
    _explanationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _explanationLabel.numberOfLines = 0;
    _explanationLabel.textColor = [UIColor flyGreen];
    _explanationLabel.font = [UIFont systemFontOfSize:EXPLANATION_TEXT_FONT_SIZE];
    
    NSString *explanationText = @"I want to follow:";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:explanationText];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = EXPLANATION_TEXT_LINE_SPACING;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, explanationText.length)];
    _explanationLabel.attributedText = attrStr;
    [_explanationLabel sizeToFit];
    
    _explanationView = [UIView new];
    _explanationView.translatesAutoresizingMaskIntoConstraints = NO;
    _explanationView.backgroundColor = [UIColor whiteColor];
    [_explanationView addSubview:_explanationLabel];
    [self.view addSubview:_explanationView];
    
    _groupsTabelView = [UITableView new];
    _groupsTabelView.backgroundColor = [UIColor clearColor];
    _groupsTabelView.delegate = self;
    _groupsTabelView.dataSource = self;
    [self.view addSubview:_groupsTabelView];
    
    _groups = [NSMutableArray new];
    [_groups addObject:@"Drugs and alcohol"];
    [_groups addObject:@"Rape"];
    [_groups addObject:@"Love confession"];
    [_groups addObject:@"LGBTQ"];
    [_groups addObject:@"Relationships"];
    
//    [_groups addObject:@"Drugs and alcohol"];
//    [_groups addObject:@"Rape"];
//    [_groups addObject:@"Love confession"];
//    [_groups addObject:@"LGBTQ"];
//    [_groups addObject:@"Relationships"];
//    
//    [_groups addObject:@"Drugs and alcohol"];
//    [_groups addObject:@"Rape"];
//    [_groups addObject:@"Love confession"];
//    [_groups addObject:@"LGBTQ"];
//    [_groups addObject:@"Relationships"];
//    [_groups addObject:@"Drugs and alcohol"];
//    [_groups addObject:@"Rape"];
//    [_groups addObject:@"Love confession"];
//    [_groups addObject:@"LGBTQ"];
//    [_groups addObject:@"Relationships"];
//    [_groups addObject:@"Drugs and alcohol"];
//    [_groups addObject:@"Rape"];
//    [_groups addObject:@"Love confession"];
//    [_groups addObject:@"LGBTQ"];
//    [_groups addObject:@"Relationships"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_groupsTabelView reloadData];
    [self updateViewConstraints];
}

- (void)_setupNavigationBar
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 32, 32)];
    [backButton setImage:[UIImage imageNamed:@"icon_navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(_backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(_nextBarButtonTapped)];
}

- (void)updateViewConstraints
{
//    [self.view removeConstraints:self.view.constraints];
    
    [_explanationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(CGRectGetWidth([[UIScreen mainScreen] bounds]));
        make.height.mas_equalTo(45);
    }];
    
    [_explanationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_explanationView).offset(15.0f);
        make.leading.mas_equalTo(_explanationView.mas_leading).offset(20.0f);
        CGFloat maxWidth = CGRectGetWidth([self.view bounds]) - FILTER_VIEW_LEFT_PADDING;
        make.width.mas_equalTo(CGRectGetWidth([self.view bounds]) - 20 - 20);
    }];
    
    [_groupsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_explanationView.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.view).offset(0);
        make.width.mas_equalTo(CGRectGetWidth([self.view bounds]));
        CGFloat maxHeight = CGRectGetHeight([self.view bounds]) -  CGRectGetMaxY(_explanationView.frame);
        CGFloat height = _groupsTabelView.contentSize.height;
        if (height >= maxHeight) {
            height = maxHeight;
        }
        make.height.mas_equalTo(height);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FLYFilterHomeFeedSelectorGroupTableCellIdentifier";
    FLYFilterSelectorGroupTableViewCell *cell = (FLYFilterSelectorGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FLYFilterSelectorGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.groupName = [_groups objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    [self updateViewConstraints];
    [FLYUtilities printAutolayoutTrace];
}

#pragma mark - navigation bar actions

- (void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
