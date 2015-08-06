//
//  UniversalViewController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYUniversalViewController.h"
#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "UIColor+FLYAddition.h"
#import "FLYBarButtonItem.h"
#import "UIViewController+StatusBar.h"
#import "FLYLoaderView.h"

#if DEBUG
#import "FLEXManager.h"
#endif

@interface FLYUniversalViewController ()

@property (nonatomic) BOOL hasSetNavigationItem;
@property (nonatomic) FLYLoaderView *loaderView;

@end

@implementation FLYUniversalViewController

- (instancetype)init
{
    if (self = [super init]) {
        _state = FLYViewControllerStateReady;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    #if DEBUG
    [[FLEXManager sharedManager] showExplorer];
    #endif
    
    UIFont *titleFont = [UIFont fontWithName:@"Avenir-Roman" size:16];
    self.flyNavigationController.flyNavigationBar.titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:titleFont};
    
    if (self.state == FLYViewControllerStateLoading) {
        [self.view addSubview:self.loaderView];
        [self.loaderView startAnimating];
    } else if (self.state == FLYViewControllerStateError) {
        
    }
}

- (FLYLoaderView *)loaderView
{
    if (_loaderView == nil) {
        _loaderView = [FLYLoaderView new];
    }
    return _loaderView;
}

- (void)setState:(FLYViewControllerState)state
{
    if (_state != state) {
        FLYViewControllerState previousState = _state;
        _state = state;
        
        if (self.isViewLoaded) {
            switch (_state) {
                case FLYViewControllerStateLoading: {
                    [self.view addSubview:self.loaderView];
                    [self.view bringSubviewToFront:self.loaderView];
                    [self.loaderView startAnimating];
                    break;
                }
                case FLYViewControllerStateError: {
                    [self.loaderView stopAnimating];
                    _loaderView = nil;
                    break;
                }
                case FLYViewControllerStateReady: {
                    [self.loaderView stopAnimating];
                    [self.loaderView removeFromSuperview];
                    _loaderView = nil;
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)updateViewConstraints
{
    if (_loaderView) {
        [_loaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
    }
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.flyNavigationController.flyNavigationBar setColor:[self preferredNavigationBarColor] animated:YES];
    [self.flyNavigationController setStatusBarColor:[self preferredStatusBarColor]];
    
    if (_state == FLYViewControllerStateLoading) {
        [self.view bringSubviewToFront:_loaderView];
        [_loaderView startAnimating];
    }
}

- (FLYNavigationController *)flyNavigationController
{
    if ([self.navigationController isKindOfClass:[FLYNavigationController class]]) {
        return  (FLYNavigationController *)(self.navigationController);
    }
    return nil;
}

- (UINavigationItem *)navigationItem
{
    if (!_hasSetNavigationItem) {
        _hasSetNavigationItem = YES;
        [self loadLeftBarButton];
        [self loadRightBarButton];
    }
    return [super navigationItem];
}

- (void)loadLeftBarButton
{
    if ([self.navigationController.viewControllers count] > 1) {
        FLYBackBarButtonItem *barItem = [FLYBackBarButtonItem barButtonItem:YES];
        __weak typeof(self)weakSelf = self;
        barItem.actionBlock = ^(FLYBarButtonItem *barButtonItem) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf _backButtonTapped];
        };
        self.navigationItem.leftBarButtonItem = barItem;
    }
}

- (void)loadRightBarButton
{
}


- (UIColor *)preferredNavigationBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredNavigationBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredNavigationBarColor)];
    }
    return [UIColor whiteColor];
}

//- (UIStatusBarStyle) preferredStatusBarStyle
//{
//    if ([self.parentViewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
////        return [[self.parentViewController performSelector:@selector(preferredStatusBarStyle)] integerValue];
//        return [self.parentViewController preferredStatusBarStyle];
//    }
//    return UIStatusBarStyleDefault;
//}

- (UIColor*)preferredStatusBarColor
{
    if ([self.parentViewController respondsToSelector:@selector(preferredStatusBarColor)]) {
        return [self.parentViewController performSelector:@selector(preferredStatusBarColor)];
    }
    return [UIColor clearColor];
}

- (void)_backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
