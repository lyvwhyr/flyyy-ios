//
//  FLYNavigationController.m
//  Fly
//
//  Created by Xingxing Xu on 11/15/14.
//  Copyright (c) 2014 Fly. All rights reserved.
//

#import "FLYNavigationController.h"
#import "FLYNavigationBar.h"
#import "FLYUniversalViewController.h"

@interface FLYNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/// A Boolean value indicating whether navigation controller is currently pushing a new view controller on the stack.
@property (nonatomic, getter = isDuringPushAnimation) BOOL duringPushAnimation;
/// A real delegate of the class. `delegate` property is used only for keeping an internal state during
/// animations – we need to know when the animation ended, and that info is available only
/// from `navigationController:didShowViewController:animated:`.
@property (weak, nonatomic) id<UINavigationControllerDelegate> realDelegate;

@end

@implementation FLYNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithNavigationBarClass:[FLYNavigationBar class] toolbarClass:[UIToolbar class]]) {
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self)weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        [self.interactivePopGestureRecognizer addTarget:self action:@selector(interactivePopGesture:)];
        self.delegate = weakSelf;
    }
}

- (FLYNavigationBar *)flyNavigationBar
{
    if ([self.navigationBar isKindOfClass:[FLYNavigationBar class]]) {
        return (FLYNavigationBar *)(self.navigationBar);
    }
    return nil;
}

- (UIViewController *)visibleViewController
{
    UIViewController *viewController = [super visibleViewController];
    if ([viewController respondsToSelector:@selector(visibleViewController)]) {
        return [viewController performSelector:@selector(visibleViewController)];
    }
    return viewController;
}

#pragma mark - UINavigationController

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    [super setDelegate:delegate ? self : nil];
    self.realDelegate = delegate != self ? delegate : nil;
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated __attribute__((objc_requires_super))
{
    self.duringPushAnimation = YES;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
//    NSCAssert(self.interactivePopGestureRecognizer.delegate == self, @"AHKNavigationController won't work correctly if you change interactivePopGestureRecognizer's delegate.");
    
    self.duringPushAnimation = NO;
    
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // disable interactivePopGestureRecognizer in the rootViewController of navigationController
        if ([[navigationController.viewControllers firstObject] isEqual:viewController]) {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        } else {
            // enable interactivePopGestureRecognizer
            navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    
    if ([self.realDelegate respondsToSelector:_cmd]) {
        [self.realDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

#pragma mark - NSObject

- (void)dealloc
{
    self.delegate = nil;
    [self.interactivePopGestureRecognizer removeTarget:self action:nil];
    self.interactivePopGestureRecognizer.delegate = nil;
}

- (void)interactivePopGesture:(UIGestureRecognizer *)interactivePopGesture
{
    if (interactivePopGesture.state == UIGestureRecognizerStateCancelled || interactivePopGesture.state == UIGestureRecognizerStateEnded) {
        _duringPushAnimation = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        // Disable pop gesture in two situations:
        // 1) when the pop animation is in progress
        // 2) when user swipes quickly a couple of times and animations don't have time to be performed
        return [self.viewControllers count] > 1 && !self.isDuringPushAnimation;
    } else {
        // default value
        return YES;
    }
}

#pragma mark - Delegate Forwarder

// Thanks for the idea goes to: https://github.com/steipete/PSPDFTextView/blob/ee9ce04ad04217efe0bc84d67f3895a34252d37c/PSPDFTextView/PSPDFTextView.m#L148-164

- (BOOL)respondsToSelector:(SEL)s
{
    return [super respondsToSelector:s] || [self.realDelegate respondsToSelector:s];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)s
{
    return [super methodSignatureForSelector:s] ?: [(id)self.realDelegate methodSignatureForSelector:s];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    id delegate = self.realDelegate;
    if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
    }
}

@end
