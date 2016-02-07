//
//  FLYPrePostViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/20/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYPrePostViewController.h"
#import "UIColor+FLYAddition.h"
#import "FLYPrePostChooseGroupTableViewCell.h"
#import "FLYPostButtonView.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "JGProgressHUDIndicatorView.h"
#import "JGProgressHUDRingIndicatorView.h"
#import "Dialog.h"
#import "FLYRecordViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FLYTopic.h"
#import "FLYGroup.h"
#import "FLYGroupManager.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYPrePostHeaderView.h"
#import "FLYFeedViewController.h"
#import "FLYEndpointRequest.h"
#import "FLYUser.h"
#import "FLYMediaService.h"
#import "FLYTopicService.h"
#import "FLYPushNotificationManager.h"
#import "UIFont+FLYAddition.h"
#import "FLYTagsManager.h"
#import "FLYTagsService.h"
#import "FLYBarButtonItem.h"
#import "NSDictionary+FLYAddition.h"
#import "UIImage+FLYAddition.h"

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"

#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 105
#define kLeftPadding    15
#define kTagButtonHorizontalSpacing 19
#define kTagButtonVerticalSpacing 12
#define kDescriptionTextTopPadding  13
#define kHillImageBottomPading 20

// pi is approximately equal to 3.14159265359.
#define   DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

@interface FLYPrePostViewController () <UITableViewDataSource, UITableViewDelegate, FLYPrePostHeaderViewDelegate, JGProgressHUDDelegate>

@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) FLYPrePostHeaderView *headerView;
@property (nonatomic) FLYPostButtonView *postButton;
@property (nonatomic) UIView *searchContainerView;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIImageView *hillBgImageView;

@property (nonatomic) NSArray *groups;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic) NSMutableArray *tagButtonArray;
@property (nonatomic) CGRect lastTagFrame;
@property (nonatomic) BOOL alreadyLayouted;

@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) FLYGroup *selectedGroup;

@property (nonatomic) CGFloat keyboardHeight;

// animation text strength
@property (nonatomic) UIBezierPath *arcPath;
@property (nonatomic) CAShapeLayer *pathLayer;
@property (nonatomic) CALayer *sunLayer;

@property (nonatomic, copy) mediaUploadSuccessBlock successBlock;
@property (nonatomic, copy) mediaUploadFailureBlock failureBlock;


@end

@implementation FLYPrePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
//    _groups = [[NSArray arrayWithArray:[FLYGroupManager sharedInstance].groupList] subarrayWithRange:NSMakeRange(0, 9)];
    
    self.title = @"Post";
    
    self.backgroundImageView = [UIImageView new];
    self.backgroundImageView.image = [UIImage imageNamed:@"bg_post_tag"];
    [self.view addSubview:self.backgroundImageView];
    
    _postButton = [FLYPostButtonView new];
    _postButton.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_postButtonTapped)];
    [_postButton addGestureRecognizer:tap];
    [self.view addSubview:_postButton];
    
    // Initialize tags
    _tagButtonArray = [NSMutableArray new];
    @weakify(self)
    [self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @strongify(self)
        FLYGroup *group = (FLYGroup *)obj;
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tagButton.layer.cornerRadius = 4.0f;
        tagButton.layer.borderColor = [UIColor flyShareTextGrey].CGColor;
        tagButton.layer.borderWidth = 1.0f;
        tagButton.tag = idx;
        tagButton.contentEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);
        tagButton.titleLabel.font = [UIFont flyFontWithSize:14.0f];
        [tagButton setTitleColor:[FLYUtilities colorWithHexString:@"#737373"] forState:UIControlStateNormal];
        [tagButton addTarget:self action:@selector(_tagSelected:) forControlEvents:UIControlEventTouchUpInside];
        [tagButton setTitle:group.groupName forState:UIControlStateNormal];
        [tagButton sizeToFit];
        [self.view addSubview:tagButton];
        [self.tagButtonArray addObject:tagButton];
    }];
    
    // search view
    _searchContainerView = [UIView new];
    _searchContainerView.userInteractionEnabled = NO;
    [self.view addSubview:_searchContainerView];
    
    self.headerView = [[FLYPrePostHeaderView alloc] initWithSearchView:self.searchContainerView];
    self.headerView.delegate = self;
    [self.view addSubview:self.headerView];
    
    
//    NSInteger minimalLen = [[FLYAppStateManager sharedInstance].configs fly_integerForKey:@"minimalPostTitleLen" defaultValue:kMinimalPostTitleLen];
//    NSString *description = [NSString stringWithFormat:LOC(@"FLYPostDescrptionText"), minimalLen];
//    _descriptionLabel = [UILabel new];
//    _descriptionLabel.numberOfLines = 0;
//    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    NSMutableAttributedString *descriptionAttr = [[NSMutableAttributedString alloc] initWithString:description];
//    
//    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    paragraphStyle.lineSpacing = 2;
//    [descriptionAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, description.length)];
//    [descriptionAttr addAttributes:@{NSFontAttributeName: [UIFont flyFontWithSize:16]} range:NSMakeRange(0, description.length)];
//    [descriptionAttr addAttributes:@{NSForegroundColorAttributeName: [UIColor flyColorFlyGreyText]} range:NSMakeRange(0, description.length)];
//    _descriptionLabel.attributedText = descriptionAttr;
//    [self.view addSubview:_descriptionLabel];

    self.hillBgImageView = [UIImageView new];
    self.hillBgImageView.image = [UIImage imageNamed:@"topic_caption_hill_bg"];
    [self.hillBgImageView sizeToFit];
    [self.view addSubview:self.hillBgImageView];
    
    [self _addObservers];
    
    [self updateViewConstraints];
    
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:nil element:nil action:@"impression"];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

-(void)loadRightBarButton
{
    FLYBarButtonItem *barButtonItem = [[FLYPostRecordingArrowButtonItem alloc] initWithSide:NO];
    @weakify(self)
    barButtonItem.actionBlock = ^(FLYBarButtonItem *item) {
        @strongify(self)
        [self _postButtonTapped];
    };
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)_addObservers
{
 [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardWillShow:)
                                              name:@"UIKeyboardWillShowNotification"
                                            object:nil];

 [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
}

- (void)_tagSelected:(UIButton *)target
{
    FLYGroup *tag = self.groups[target.tag];
    NSString *tagName = tag.groupName;
    [self.headerView addTagWithTagName:tagName];
}

- (void)updateViewConstraints
{
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 15);
        make.leading.equalTo(self.view).offset(kLeftPadding);
        make.trailing.equalTo(self.view).offset(-kLeftPadding);
        make.height.equalTo(@105);
    }];
    
    [_postButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@(kFlyPostButtonHeight));
    }];
    
    [self.searchContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.descriptionTextView.mas_bottom).offset(5);
        make.leading.equalTo(self.view).offset(kLeftPadding);
        make.trailing.equalTo(self.view).offset(-kLeftPadding);
        make.bottom.equalTo(self.view).offset(-self.keyboardHeight);
    }];
    
//    [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.headerView.mas_bottom).offset(30);
//        make.leading.equalTo(self.view).offset(15);
//        make.trailing.equalTo(self.view).offset(-15);
//    }];
    
    [self.hillBgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-self.keyboardHeight - kHillImageBottomPading);
    }];
    
    self.alreadyLayouted = YES;
    [super updateViewConstraints];
    
}

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
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_%d%d", kFlyPrePostChooseGroupCellIdentifier, (int)indexPath.section, (int)indexPath.row];
    cell = [[FLYPrePostChooseGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    FLYPrePostChooseGroupTableViewCell *chooseGroupCell = (FLYPrePostChooseGroupTableViewCell *)cell;
    FLYGroup *group = [_groups objectAtIndex:indexPath.row];
    chooseGroupCell.groupName = group.groupName;
    cell = chooseGroupCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    //Set the button state
    if ([self.selectedIndex isEqual:indexPath]) {
        [chooseGroupCell selectCell];
    }
    
    return cell;
}


- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYPrePostChooseGroupTableViewCell *cell = (FLYPrePostChooseGroupTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([self.selectedIndex isEqual:indexPath]) {
        //unselect
        self.selectedIndex = nil;
        self.selectedGroup = nil;
        [cell selectCell];
    } else {
        // deselect previous selected cell
        FLYPrePostChooseGroupTableViewCell *previousSelectedCell = (FLYPrePostChooseGroupTableViewCell *)[tableView cellForRowAtIndexPath:self.selectedIndex];
        [previousSelectedCell selectCell];
        
        // select the cell
        [cell selectCell];
        self.selectedIndex = indexPath;
        self.selectedGroup = [self.groups objectAtIndex:indexPath.row];
    }
}

#pragma mark - FLYPrePostTitleTableViewCellDelegate
- (BOOL)titleTextViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)titleTextViewShouldEndEditing:(UITextView *)textView
{
    self.topicTitle = textView.text;
    [self updateViewConstraints];
    return YES;
}

- (void)searchViewWillAppear:(FLYPrePostHeaderView *)view
{
    self.descriptionLabel.hidden = YES;
    self.searchContainerView.userInteractionEnabled = YES;
}

- (void)searchViewWillDisappear:(FLYPrePostHeaderView *)view
{
    self.descriptionLabel.hidden = NO;
    self.searchContainerView.userInteractionEnabled = NO;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger oldLen = [textView.text length];
    NSUInteger newLen = [textView.text length] + [text length] - range.length;
    [self _animatePathWithOldLen:oldLen newLen:newLen];
    return YES;
}

- (void)_animatePathWithOldLen:(NSInteger)oldLen newLen:(NSInteger)newLen
{
    if (self.pathLayer) {
        [self.sunLayer removeFromSuperlayer];
        self.sunLayer = nil;
        
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
    }
    
    if (oldLen == newLen) {
        return;
    }
    BOOL clockwise = YES;
    if (newLen < oldLen) {
        clockwise = NO;
    }
    
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pading = 20;
    CGFloat radius = (1.72/3 * (screenWidth - pading * 2)/2) * 2;
    
    CGFloat centerY =  CGRectGetHeight(self.view.bounds) - (self.keyboardHeight + CGRectGetHeight(self.hillBgImageView.bounds) + kHillImageBottomPading) + (1.72/3 * (screenWidth - pading * 2)/2) + 20; // 20 pading
    
    
    NSInteger steps = 41;
    CGFloat startAngle = (M_PI + M_PI/6.0) + oldLen * M_PI * 2/3.0 * 1.0/steps;
    CGFloat endAngle = (M_PI + M_PI/6.0) + newLen * M_PI * 2/3.0 * 1.0/steps;
    
    self.arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(screenWidth/2.0f, centerY)
                                                         radius:radius
                                                     startAngle:startAngle
                                                       endAngle:endAngle
                                                      clockwise:clockwise];
    
    self.pathLayer = [CAShapeLayer layer];
    self.pathLayer.frame = self.view.bounds;
    self.pathLayer.strokeColor = [FLYUtilities colorWithHexString:@"#8e8e93" alpha:0.7].CGColor;
    self.pathLayer.fillColor     = [UIColor clearColor].CGColor;
    self.pathLayer.lineCap = kCALineCapSquare;
    self.pathLayer.path = self.arcPath.CGPath;
    self.pathLayer.lineWidth = 1.0f;
    self.pathLayer.strokeStart = 0.0f;
    self.pathLayer.strokeEnd = 0.2f;
    [self.view.layer addSublayer:self.pathLayer];
    
    UIImage *sunImage = [UIImage imageNamed:@"topic_caption_sun"];;
    if (newLen < (steps/4)) {
        sunImage = [UIImage imageNamed:@"topic_caption_sun"];
    } else if (newLen < (steps/2)) {
        sunImage = [sunImage imageWithColorOverlay:[FLYUtilities colorWithHexString:@"#DCAC47"]];
    } else if (newLen < (steps * 0.75)) {
        sunImage = [sunImage imageWithColorOverlay:[FLYUtilities colorWithHexString:@"#DCC147"]];
    } else if (newLen < steps){
        sunImage = [sunImage imageWithColorOverlay:[FLYUtilities colorWithHexString:@"#B5DC47"]];
    } else {
        sunImage = [sunImage imageWithColorOverlay:[FLYUtilities colorWithHexString:@"#48DC47"]];
    }
    self.sunLayer = [CALayer layer];
    self.sunLayer.contents = (id)sunImage.CGImage;
    self.sunLayer.frame = CGRectMake(0.0f, 0.0f, sunImage.size.width, sunImage.size.height);
    [self.pathLayer addSublayer:self.sunLayer];
    
    CAKeyframeAnimation *sunAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    sunAnimation.fillMode = kCAFillModeForwards;
    sunAnimation.removedOnCompletion = NO;
    sunAnimation.duration = 0.2;
    sunAnimation.path = self.pathLayer.path;
    sunAnimation.calculationMode = kCAAnimationPaced;
    sunAnimation.delegate = self;
    [self.sunLayer addAnimation:sunAnimation forKey:@"position"];
}

#pragma mark - button tap actions

- (void)_postButtonTapped
{
    self.topicTitle = self.headerView.descriptionTextView.text;
    NSDictionary *properties = @{kTrackingSection: @"post_page", kTrackingComponent:@"post",  kTrackingElement:@"post_button", kTrackingAction:@"click"};
    [[Mixpanel sharedInstance]  track:@"recording_flow" properties:properties];
    
    NSString *defaultStr = LOC(@"FLYPrePostDefaultText");
    
    NSInteger minimalLen = [[FLYAppStateManager sharedInstance].configs fly_integerForKey:@"minimalPostTitleLen" defaultValue:kMinimalPostTitleLen];
    if ((self.topicTitle.length < minimalLen) || [self.topicTitle isEqualToString:defaultStr]) {
        [Dialog simpleToast:[NSString stringWithFormat:LOC(@"FLYPostMustMinLength"), minimalLen]];
        return;
    }
    
//    if (![self _hasHashTag:self.topicTitle]) {
//        [Dialog simpleToast:LOC(@"FLYPostMustHaveAgroup")];
//        return;
//    }
    
    
    if (self.defaultGroup) {
        self.topicTitle = [NSString stringWithFormat:@"%@ #%@", self.topicTitle, self.defaultGroup.groupName];
    }
    
    BOOL mediaAlreadyUploaded = [FLYAppStateManager sharedInstance].mediaAlreadyUploaded;
    NSString *userId = [FLYAppStateManager sharedInstance].currentUser.userId;
    
    self.postButton.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (mediaAlreadyUploaded) {
        [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
    } else {
        //If media id is still empty at this point, try to upload the media again.
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.delegate = self;
        HUD.textLabel.text = @"Posting...";
        [HUD showInView:self.view];
        
        @weakify(self)
        FLYUploadToS3SuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
            @strongify(self);
            [HUD dismiss];
            [self _serviceCreateTopicWithParams:@{@"user_id":userId}];
        };
        
        
        FLYUploadToS3ErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            self.postButton.userInteractionEnabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [HUD dismiss];
            [Dialog simpleToast:LOC(@"FLYGenericError")];
        };
        [FLYMediaService getSignedUrlAndUploadWithSuccessBlock:successBlock errorBlock:errorBlock];
    }
}

- (BOOL)_hasHashTag:(NSString *)str
{
    BOOL hasHashTag = NO;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [str substringWithRange:wordRange];
        NSLog(@"Found tag %@", word);
        hasHashTag = YES;
        break;
    }
    return hasHashTag;
}

#pragma mark - Service
- (void)_serviceCreateTopicWithParams:(NSDictionary *)dict
{
    NSDictionary *initialParams = @{@"topic_title": self.topicTitle,
                             @"media_id":[FLYAppStateManager sharedInstance].mediaId,
                             @"extension":@"m4a",
                             @"audio_duration":@(self.audioDuration)
                             };
    
    NSMutableDictionary *params = [initialParams mutableCopy];
    if (self.selectedGroup) {
        [params setObject:self.selectedGroup.groupId forKey:@"group_id"];
    }
    
    @weakify(self)
    FLYPostTopicSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObj) {
        @strongify(self)
        FLYTopic *post = [[FLYTopic alloc] initWithDictory:responseObj];
        NSDictionary *dict = @{kNewPostKey:post};
        [Dialog simpleToast:@"Posted"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewPostReceivedNotification object:self userInfo:dict];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        self.postButton.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (post.tags && post.tags.count > 0) {
            [[FLYTagsManager sharedInstance] updateCurrentUserTags:post.tags];
        }
    };
    
    FLYPostTopicErrorBlock errorBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self)
        self.postButton.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        UALog(@"Post error %@", error);
    };
    
    [FLYTopicService postTopic:params successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark - Navigation bar and status barhow
- (UIColor *)preferredNavigationBarColor
{
    return [UIColor flyBlue];
}

- (UIColor*)preferredStatusBarColor
{
    return [UIColor flyBlue];
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardHeight = kbSize.height;
    
    [self updateViewConstraints];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    self.keyboardHeight = 44;
    [self updateViewConstraints];
}

@end
