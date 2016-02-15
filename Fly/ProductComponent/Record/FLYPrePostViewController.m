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
#import "SDVersion.h"
#import "UIImage+FLYAddition.h"

#define kFlyPrePostTitleCellIdentifier @"flyPrePostTitleCellIdentifier"
#define kFlyPrePostChooseGroupCellIdentifier @"flyPrePostChooseGroupCellIdentifier"

#define kFlyPostButtonHeight 44
#define kTitleTextCellHeight 105
#define kLeftPadding    15
#define kTagButtonHorizontalSpacing 19
#define kTagButtonVerticalSpacing 12
#define kDescriptionTextTopPadding  13
#define kHillImageBottomPading 10

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

@property (nonatomic) UIImageView *sunView1;
@property (nonatomic) UIImageView *sunView2;
@property (nonatomic) UIImageView *sunView3;
@property (nonatomic) UIImageView *sunView4;
@property (nonatomic) UIImageView *sunView5;

@property (nonatomic, copy) mediaUploadSuccessBlock successBlock;
@property (nonatomic, copy) mediaUploadFailureBlock failureBlock;


@end

@implementation FLYPrePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
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
    
    
    DeviceSize deviceSize = [SDVersion deviceSize];
    if (deviceSize >= Screen4Dot7inch) {
        NSString *description = LOC(@"FLYPostDescrptionText");
        _descriptionLabel = [UILabel new];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *descriptionAttr = [[NSMutableAttributedString alloc] initWithString:description];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 2;
        [descriptionAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, description.length)];
        [descriptionAttr addAttributes:@{NSFontAttributeName: [UIFont flyFontWithSize:18]} range:NSMakeRange(0, description.length)];
        [descriptionAttr addAttributes:@{NSForegroundColorAttributeName: [FLYUtilities colorWithHexString:@"#D6D6D6"]} range:NSMakeRange(0, description.length)];
        _descriptionLabel.attributedText = descriptionAttr;
        [self.view addSubview:_descriptionLabel];
    }

    if ([SDVersion deviceSize] >= Screen4inch) {
        self.hillBgImageView = [UIImageView new];
        self.hillBgImageView.image = [UIImage imageNamed:@"topic_caption_hill_bg"];
        [self.hillBgImageView sizeToFit];
        [self.view addSubview:self.hillBgImageView];
    }
    
    [self _addSunView];
    [self _addObservers];
    
    [self updateViewConstraints];
    
    [[FLYScribe sharedInstance] logEvent:@"recording_flow" section:@"post_page" component:nil element:nil action:@"impression"];
}

- (void)_addSunView
{
    UIImage *sunImage = [UIImage imageNamed:@"sun_grey"];
//    sunImage = [sunImage imageWithColorOverlay:[FLYUtilities colorWithHexString:@"#F2F2F2"]];
    
    self.sunView1 = [UIImageView new];
    self.sunView1.translatesAutoresizingMaskIntoConstraints = NO;
    self.sunView1.image = sunImage;
    [self.sunView1 sizeToFit];
    [self.view addSubview:self.sunView1];
    
    self.sunView2 = [UIImageView new];
    self.sunView2.translatesAutoresizingMaskIntoConstraints = NO;
    self.sunView2.image = sunImage;
    [self.sunView2 sizeToFit];
    [self.view addSubview:self.sunView2];
    
    self.sunView3 = [UIImageView new];
    self.sunView3.translatesAutoresizingMaskIntoConstraints = NO;
    self.sunView3.image = sunImage;
    [self.sunView3 sizeToFit];
    [self.view addSubview:self.sunView3];
    
    self.sunView4 = [UIImageView new];
    self.sunView4.translatesAutoresizingMaskIntoConstraints = NO;
    self.sunView4.image = sunImage;
    [self.sunView4 sizeToFit];
    [self.view addSubview:self.sunView4];
    
    self.sunView5 = [UIImageView new];
    self.sunView5.translatesAutoresizingMaskIntoConstraints = NO;
    self.sunView5.image = sunImage;
    [self.sunView5 sizeToFit];
    [self.view addSubview:self.sunView5];
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
    
    
    if (self.descriptionLabel) {
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom).offset(15);
            make.leading.equalTo(self.view).offset(25);
            make.trailing.equalTo(self.view).offset(-25);
        }];
    }
    
    if (self.hillBgImageView) {
        [self.hillBgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-self.keyboardHeight + 5);
        }];
    }
    
    CGFloat circlePadding = 80;
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat radius = (screenWidth - 2 * circlePadding) / 2.0f;
    CGFloat centerY = CGRectGetHeight(self.view.bounds) - (self.keyboardHeight + CGRectGetHeight(self.hillBgImageView.bounds)/2 + 10);
    CGFloat centerX = screenWidth / 2.0f;
//    CGFloat imageSize = CGRectGetHeight(self.sunView1.bounds);
    CGFloat imageSize = 36;
    
    
    CGFloat startAngle = M_PI;
    CGFloat endAngle = 2* M_PI;
    
    self.arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                                  radius:radius
                                              startAngle:startAngle
                                                endAngle:endAngle
                                               clockwise:YES];
    
    self.pathLayer = [CAShapeLayer layer];
    self.pathLayer.frame = self.view.bounds;
    self.pathLayer.strokeColor = [UIColor clearColor].CGColor;
    self.pathLayer.fillColor     = [UIColor clearColor].CGColor;
    self.pathLayer.lineCap = kCALineCapSquare;
    self.pathLayer.path = self.arcPath.CGPath;
    self.pathLayer.lineWidth = 0.5f;
    self.pathLayer.strokeStart = 0.0f;
    self.pathLayer.strokeEnd = 1.0f;
    self.pathLayer.opacity = 0.3f;
    [self.view.layer addSublayer:self.pathLayer];
    

    
    [self.sunView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@(circlePadding - imageSize/2.0f));
        make.top.equalTo(@(centerY - imageSize/2.0f));
        make.width.equalTo(@(imageSize));
        make.height.equalTo(@(imageSize));
    }];
    
    [self.sunView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(centerX - imageSize/2.0f - sqrt(2)/2 * radius + radius * 1/8.0);
        make.top.equalTo(self.view).offset(centerY - sqrt(2)/2 * radius - imageSize/2.0f + radius * 1/4.0);
        make.width.equalTo(@(imageSize));
        make.height.equalTo(@(imageSize));
    }];
    
    [self.sunView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(centerX - imageSize/2.0f);
        make.top.equalTo(self.view).offset(centerY - radius - imageSize/2.0f + radius * 1/4.0);
        make.width.equalTo(@(imageSize));
        make.height.equalTo(@(imageSize));
    }];
    
    [self.sunView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-(centerX - imageSize/2.0f - sqrt(2)/2 * radius + radius * 1/8.0));
        make.top.equalTo(self.sunView2);
        make.width.equalTo(@(imageSize));
        make.height.equalTo(@(imageSize));
    }];
    
    
    [self.sunView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-(circlePadding - imageSize/2.0f));
        make.top.equalTo(self.sunView1);
        make.width.equalTo(@(imageSize));
        make.height.equalTo(@(imageSize));
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
    if ([SDVersion deviceSize] >= Screen4inch) {
        [self _animatePathWithOldLen:oldLen newLen:newLen];
    }
    return YES;
}

- (void)_animatePathWithOldLen:(NSInteger)oldLen newLen:(NSInteger)newLen
{
    NSInteger interval = 8;
    
    if (oldLen == newLen) {
        return;
    }
    
    UIImage *greyImage = [UIImage imageNamed:@"sun_grey"];
    UIImage *yellowImage = [UIImage imageNamed:@"sun_yellow"];
    if (newLen >= (interval * 5)) {
        self.sunView1.image = yellowImage;
        self.sunView2.image = yellowImage;
        self.sunView3.image = yellowImage;
        self.sunView4.image = yellowImage;
        self.sunView5.image = yellowImage;
    } else if (newLen >= (interval * 4)) {
        self.sunView1.image = yellowImage;
        self.sunView2.image = yellowImage;
        self.sunView3.image = yellowImage;
        self.sunView4.image = yellowImage;
        self.sunView5.image = greyImage;
    } else if (newLen >= (interval * 3)) {
        self.sunView1.image = yellowImage;
        self.sunView2.image = yellowImage;
        self.sunView3.image = yellowImage;
        self.sunView4.image = greyImage;
        self.sunView5.image = greyImage;
    } else if (newLen >= (interval * 2)) {
        self.sunView1.image = yellowImage;
        self.sunView2.image = yellowImage;
        self.sunView3.image = greyImage;
        self.sunView4.image = greyImage;
        self.sunView5.image = greyImage;
    } else if (newLen >= (interval * 1)) {
        self.sunView1.image = yellowImage;
        self.sunView2.image = greyImage;
        self.sunView3.image = greyImage;
        self.sunView4.image = greyImage;
        self.sunView5.image = greyImage;
    } else {
        self.sunView1.image = greyImage;
        self.sunView2.image = greyImage;
        self.sunView3.image = greyImage;
        self.sunView4.image = greyImage;
        self.sunView5.image = greyImage;
    }
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
    if (!self.keyboardHeight) {
        self.keyboardHeight = kbSize.height;
    }
    
    [self updateViewConstraints];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [self updateViewConstraints];
}

@end
