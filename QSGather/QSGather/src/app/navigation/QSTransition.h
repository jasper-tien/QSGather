//
//  QSTransition.h
//  QSGather
//
//  Created by tianmaotao on 2021/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QSTransitionType) {
    QSTransitionPush = 0,
    QSTransitionPop,
};

@protocol QSTransitionDelegate <NSObject>

- (void)willUpdateInteractiveTransition:(CGFloat)percentComplete;

- (void)willInvokePushingAnimatedTransition;

- (void)willInvokePoppingAnimatedTransition;

- (void)willRevertPushingAnimatedTransition;

- (void)willRevertPoppingAnimatedTransition;

- (void)willBeginAnimationWithOperation:(QSTransitionType)operation;

@end

@protocol QSTransitionProtocol <NSObject>

@property (nonatomic, weak) id<QSTransitionDelegate> delegate;

@end

@interface QSTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, QSTransitionProtocol>

@property (nonatomic, assign) BOOL interation;

@property (nonatomic, assign, readonly) BOOL transiting;

- (void)setAnimateTransitionType:(QSTransitionType)type;

@end

NS_ASSUME_NONNULL_END
