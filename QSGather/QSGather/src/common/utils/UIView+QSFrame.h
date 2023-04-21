//
//  UIView+QSFrame.h
//  QSGather
//
//  Created by tianmaotao on 2022/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QSFrame)

@property (nonatomic, assign) CGPoint viewOrigin;
@property (nonatomic, assign) CGSize viewSize;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat viewMinX;
@property (nonatomic, assign) CGFloat viewMinY;
@property (nonatomic, assign) CGFloat viewMaxX;
@property (nonatomic, assign) CGFloat viewMaxY;
@property (nonatomic, assign) CGFloat viewMidX;
@property (nonatomic, assign) CGFloat viewMidY;

@end

NS_ASSUME_NONNULL_END
