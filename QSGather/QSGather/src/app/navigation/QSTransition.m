//
//  QSTransition.m
//  QSGather
//
//  Created by tianmaotao on 2021/11/3.
//

#import "QSTransition.h"

@interface QSTransition ()
@property (nonatomic, assign) QSTransitionType transitionType;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, assign) BOOL transiting;
@end

@implementation QSTransition

@synthesize delegate = _delegate;

- (instancetype)init {
    if (self = [super init]) {
        _transitionType = QSTransitionPush;
    }
    return self;
}

- (void)setAnimateTransitionType:(QSTransitionType)type {
    self.transitionType = type;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(willBeginAnimationWithOperation:)]) {
        [self.delegate willBeginAnimationWithOperation:self.transitionType];
    }
    self.transiting = YES;
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containerView = [transitionContext containerView];
    if (self.transitionType == QSTransitionPush) {
        CGRect toFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
        toFrame = CGRectOffset(toFrame, toFrame.size.width, 0);
        [containerView addSubview:fromView];
        [containerView addSubview:toView];
        toView.frame = toFrame;
    } else {
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        CGRect toFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
        toView.frame = toFrame;
        CGRect fromFrame = [transitionContext initialFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]];
        fromView.frame = fromFrame;
    }
    self.transitionContext = transitionContext;
    if (!transitionContext.interactive) {
        [self finishInteractiveTransition];
    } else {
        self.transitionContext = transitionContext;
    }
}

- (void)_pushAnimatedTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(willInvokePushingAnimatedTransition)]) {
        [self.delegate willInvokePushingAnimatedTransition];
    }
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        toView.frame = (CGRect) {
            .origin.y = toView.frame.origin.y,
            .origin.x = 0,
            .size = toView.frame.size,
        };
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [fromView removeFromSuperview];
        self.transitionContext = nil;
        self.transiting = NO;
    }];
}

- (void)_popAnimatedTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(willInvokePoppingAnimatedTransition)]) {
        [self.delegate willInvokePoppingAnimatedTransition];
    }
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    CGRect fullFrame = [self.transitionContext viewForKey:UITransitionContextFromViewKey].bounds;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        fromView.frame = CGRectOffset(fullFrame, fullFrame.size.width, 0);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [fromView removeFromSuperview];
        self.transitionContext = nil;
        self.transiting = NO;
    }];
}

- (void)_revertPushingAnimatedTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(willRevertPushingAnimatedTransition)]) {
        [self.delegate willRevertPushingAnimatedTransition];
    }
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    CGRect fullFrame = [self.transitionContext viewForKey:UITransitionContextFromViewKey].bounds;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        toView.frame = (CGRect) {
            .origin.y = toView.frame.origin.y,
            .origin.x = CGRectGetMaxX(fullFrame),
            .size = toView.frame.size,
        };
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:NO];
        [toView removeFromSuperview];
        self.transitionContext = nil;
        self.transiting = NO;
    }];
}

- (void)_revertPoppingAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(willRevertPoppingAnimatedTransition)]) {
        [self.delegate willRevertPoppingAnimatedTransition];
    }
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        fromView.frame = (CGRect) {
            .origin.y = fromView.frame.origin.y,
            .origin.x = 0,
            .size = toView.frame.size,
        };
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:NO];
        [toView removeFromSuperview];
        self.transitionContext = nil;
        self.transiting = NO;
    }];
}

#pragma mark - override

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    if ([self.delegate respondsToSelector:@selector(willUpdateInteractiveTransition:)]) {
        [self.delegate willUpdateInteractiveTransition:percentComplete];
    }
    [super updateInteractiveTransition:percentComplete];
    UIView *view = nil;
    CGRect fullFrame = [self.transitionContext viewForKey:UITransitionContextFromViewKey].bounds;
    CGFloat beginX = 0;
    CGFloat endX = 0;
    if (self.transitionType == QSTransitionPush) {
        beginX = CGRectGetMaxX(fullFrame);
        endX = 0;
        view = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        beginX = 0;
        endX = CGRectGetMaxX(fullFrame);
        view = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    }
    view.frame = (CGRect) {
        .origin.x = beginX + (endX - beginX) * percentComplete,
        .origin.y = view.frame.origin.y,
        .size = view.frame.size,
    };
}

- (void)finishInteractiveTransition {
    if (self.transitionType == QSTransitionPush) {
        [self _pushAnimatedTransition:self.transitionContext];
    } else {
        [self _popAnimatedTransition:self.transitionContext];
    }
    [super finishInteractiveTransition];
}

- (void)cancelInteractiveTransition {
    if (self.transitionType == QSTransitionPush) {
        [self _revertPushingAnimatedTransition:self.transitionContext];
    } else {
        [self _revertPoppingAnimateTransition:self.transitionContext];
    }
    [super cancelInteractiveTransition];
}

@end
