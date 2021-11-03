//
//  QSNavigationController.h
//  QSGather
//
//  Created by tianmaotao on 2021/11/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QSNavigationController;
@protocol QSNavigationControllerDelegate <NSObject>

@optional

- (void)navigationControllerWillBeginAnimation:(QSNavigationController *)navigationController operation:(UINavigationControllerOperation)operation;

- (void)navigationController:(QSNavigationController *)navigationController willUpdateInteractiveTransition:(CGFloat)percentComplete;

- (void)navigationControllerWillInvokePushingAnimatedTransition:(QSNavigationController *)navigationController;

- (void)navigationControllerWillInvokePoppingAnimatedTransition:(QSNavigationController *)navigationController;

- (void)navigationControllerWillRevertPushingAnimatedTransition:(QSNavigationController *)navigationController;

- (void)navigationControllerWillRevertPoppingAnimatedTransition:(QSNavigationController *)navigationController;

- (void)navigationController:(QSNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)navigationController:(QSNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface QSNavigationController : UINavigationController

@property (nonatomic, weak, null_unspecified) id<QSNavigationControllerDelegate> animationDelegate;

@end

NS_ASSUME_NONNULL_END
