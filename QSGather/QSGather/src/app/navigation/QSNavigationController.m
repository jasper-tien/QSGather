//
//  QSNavigationController.m
//  QSGather
//
//  Created by tianmaotao on 2021/11/3.
//

#import "QSNavigationController.h"
#import "QSTransition.h"

@interface QSNavigationController ()<UINavigationControllerDelegate, QSTransitionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) QSTransition  *transition;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation QSNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.view.exclusiveTouch = YES;
    self.transition = [[QSTransition alloc] init];
    self.transition.delegate = self;
    self.interactivePopGestureRecognizer.enabled = NO;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(_panNavigationController:)];
    pan.delegate = self;
    self.pan = pan;
    [self.view addGestureRecognizer:pan];
}

#pragma mark - UIPanGestureRecognizer

- (void)_panNavigationController:(UIPanGestureRecognizer *)pan {
    CGFloat transitionX = [pan translationInView:nil].x;
    CGFloat persent = transitionX / pan.view.frame.size.width;
    persent = MAX(MIN(0.99, persent), 0);
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            self.transition.interation = YES;
            [self popViewControllerAnimated:YES];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            [self.transition updateInteractiveTransition:persent];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            if (persent > 0.5 || [pan velocityInView:nil].x > 500) {
                [self.transition finishInteractiveTransition];
            } else {
                [self.transition cancelInteractiveTransition];
            }
            self.transition.interation = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark - override

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count <= 1) {
        return nil;
    }
    UIViewController *topViewController = self.topViewController;
    [self popToRootViewControllerAnimated:animated];
    return topViewController;
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *originalViewControllers = self.viewControllers;
    NSArray<UIViewController *> *ret = [super popToRootViewControllerAnimated:animated];
    if (!animated && originalViewControllers.count > 1) {
        if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillBeginAnimation:operation:)]) {
            [self.animationDelegate navigationControllerWillBeginAnimation:self operation:UINavigationControllerOperationPop];
        }
        if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillInvokePoppingAnimatedTransition:)]) {
            [self.animationDelegate navigationControllerWillInvokePoppingAnimatedTransition:self];
        }
    }
    return ret;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if (!animated) {
        if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillBeginAnimation:operation:)]) {
            [self.animationDelegate navigationControllerWillBeginAnimation:self operation:UINavigationControllerOperationPush];
        }
        if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillInvokePushingAnimatedTransition:)]) {
            [self.animationDelegate navigationControllerWillInvokePushingAnimatedTransition:self];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.pan) {
        if (self.viewControllers.count <= 1) {
            return NO;
        }
        if (self.transition.transiting) {
            return NO;
        }
        CGPoint velocity = [self.pan velocityInView:self.pan.view];
        if (velocity.x > 50.f && ABS(velocity.y) / velocity.x < .8f) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.transition.interation ? self.transition : nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
                                        fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  {
    if (operation == UINavigationControllerOperationPop) {
        [self.transition setAnimateTransitionType:QSTransitionPop];
    } else {
        [self.transition setAnimateTransitionType:QSTransitionPush];
    }
    return self.transition;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController setNavigationBarHidden:YES animated:NO];
    if (self.animationDelegate && [self.animationDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.animationDelegate navigationController:self willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.animationDelegate && [self.animationDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.animationDelegate navigationController:self didShowViewController:viewController animated:animated];
    }
}

#pragma mark - BBPgcPadExtendedTransitionDelegate

- (void)willBeginAnimationWithOperation:(QSTransitionType)operation {
    if (![self.animationDelegate respondsToSelector:@selector(navigationControllerWillBeginAnimation:operation:)]) {
        return;
    }
    if (operation == QSTransitionPush) {
        [self.animationDelegate navigationControllerWillBeginAnimation:self operation:(UINavigationControllerOperationPush)];
    } else {
        [self.animationDelegate navigationControllerWillBeginAnimation:self operation:(UINavigationControllerOperationPop)];
    }
}

- (void)willUpdateInteractiveTransition:(CGFloat)percentComplete {
    if ([self.animationDelegate respondsToSelector:@selector(navigationController:willUpdateInteractiveTransition:)]) {
        [self.animationDelegate navigationController:self willUpdateInteractiveTransition:percentComplete];
    }
}

- (void)willInvokePushingAnimatedTransition {
    if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillInvokePushingAnimatedTransition:)]) {
        [self.animationDelegate navigationControllerWillInvokePushingAnimatedTransition:self];
    }
}

- (void)willInvokePoppingAnimatedTransition {
    if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillInvokePoppingAnimatedTransition:)]) {
        [self.animationDelegate navigationControllerWillInvokePoppingAnimatedTransition:self];
    }
}

- (void)willRevertPushingAnimatedTransition {
    if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillRevertPushingAnimatedTransition:)]) {
        [self.animationDelegate navigationControllerWillRevertPushingAnimatedTransition:self];
    }
}

- (void)willRevertPoppingAnimatedTransition {
    if ([self.animationDelegate respondsToSelector:@selector(navigationControllerWillRevertPoppingAnimatedTransition:)]) {
        [self.animationDelegate navigationControllerWillRevertPoppingAnimatedTransition:self];
    }
}

@end
