//
//  UIView+QSFrame.m
//  QSGather
//
//  Created by tianmaotao on 2022/7/27.
//

#import "UIView+QSFrame.h"

@implementation UIView (QSFrame)

- (CGPoint)viewOrigin
{
    return self.frame.origin;
}

- (CGSize)viewSize
{
    return self.bounds.size;
}

- (CGFloat)viewWidth
{
    return self.bounds.size.width;
}

- (CGFloat)viewHeight
{
    return self.bounds.size.height;
}

- (CGFloat)viewMinX
{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)viewMinY
{
    return CGRectGetMinY(self.frame);
}

- (CGFloat)viewMaxX
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)viewMaxY
{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)viewMidX
{
    return CGRectGetMidX(self.frame);
}

- (CGFloat)viewMidY
{
    return CGRectGetMidY(self.frame);
}

- (void)setViewOrigin:(CGPoint)viewOrigin
{
    CGRect frame = self.frame;
    frame.origin = viewOrigin;
    self.frame = frame;
}

- (void)setViewSize:(CGSize)viewSize
{
    CGRect frame = self.frame;
    frame.size = viewSize;
    self.frame = frame;
}

- (void)setViewWidth:(CGFloat)viewWidth
{
    CGRect frame = self.frame;
    frame.size.width = viewWidth;
    self.frame = frame;
}

- (void)setViewHeight:(CGFloat)viewHeight
{
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
}

- (void)setViewMinX:(CGFloat)viewMinX
{
    CGRect frame = self.frame;
    frame.origin.x = viewMinX;
    self.frame = frame;
}

- (void)setViewMinY:(CGFloat)viewMinY
{
    CGRect frame = self.frame;
    frame.origin.y = viewMinY;
    self.frame = frame;
}

- (void)setViewMaxX:(CGFloat)viewMaxX
{
    CGRect frame = self.frame;
    frame.origin.x = viewMaxX - frame.size.width;
    self.frame = frame;
}

- (void)setViewMaxY:(CGFloat)viewMaxY
{
    CGRect frame = self.frame;
    frame.origin.y = viewMaxY - frame.size.height;
    self.frame = frame;
}

- (void)setViewMidX:(CGFloat)viewMidX
{
    CGRect frame = self.frame;
    frame.origin.x = viewMidX - frame.size.width * 0.5;
    self.frame = frame;
}

- (void)setViewMidY:(CGFloat)viewMidY
{
    CGRect frame = self.frame;
    frame.origin.y = viewMidY - frame.size.height * 0.5;
    self.frame = frame;
}

@end
