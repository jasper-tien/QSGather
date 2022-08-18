//
//  BBPgcTabBarView.m
//  bilianime
//
//  Created by 清觞 on 2021/4/6.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import "BBPgcTabBarView.h"
#import "BBPgcTabBarItem.h"
#import "UIView+QSFrame.h"

static CGFloat kPgcTabBarAnimatedDuration = 0.3;

@interface BBPgcTabBarView () {
    UIView *_selectIndicator;
    UIScrollView *_scrollView;
    
    NSUInteger _selectedIndex;
    NSUInteger _itemCount;
    NSArray<UIView<BBPgcTabBarItemProtocol> *> *_itemViews;
    
    __weak id<BBPgcTabBarDelegate> _delegate;
}

@end

@implementation BBPgcTabBarView
@synthesize indicatorHidden = _indicatorHidden;
@synthesize indicatorAnimated = _indicatorAnimated;
@synthesize indicatorHeight = _indicatorHeight;
@synthesize itemSpacing = _itemSpacing;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.indicatorAnimated = YES;
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    [self _updateItemsLayout];
    [self _updateSelectIndicatorLayout];
}

#pragma mark - Public

- (UIView *)selectIndicatorView {
    return _selectIndicator;
}

- (NSUInteger)selectedIndex {
    return _selectedIndex;
}

- (NSUInteger)itemCount {
    return _itemCount;;
}

#pragma mark - BBPgcTabBarProtocol
- (void)reloadData {
    NSArray<UIView<BBPgcTabBarItemProtocol> *> *itemViews = [self _createAndConfigItemViews];
    _itemCount = itemViews ? itemViews.count : 0;
    [self _replaceItemViews:itemViews];
    [self _updateItemsLayout];
    [self _updateSelectIndicatorLayout];
}

- (void)selectToIndex:(NSUInteger)index animated:(BOOL)animated {
    [self _switchItemWithIndex:index animated:animated completion:nil];
}

- (void)updateWithProgress:(CGFloat)progress relativeProgress:(CGFloat)relativeProgress leftIndex:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex {
    if (isnan(progress) || isnan(relativeProgress) || isnan(leftIndex) || isnan(rightIndex)) {
        return;
    }
    UIView<BBPgcTabBarItemProtocol> *leftView = [self getTabBarItemByIndex:leftIndex];
    UIView<BBPgcTabBarItemProtocol> *rightView = [self getTabBarItemByIndex:rightIndex];
    if (!leftView || !rightView) {
        return;
    }
    
    CGFloat leftViewPointX = CGRectGetMinX(leftView.frame);
    CGFloat rightViewPointX = CGRectGetMinX(rightView.frame);
    CGFloat leftViewWidth = CGRectGetWidth(leftView.frame);
    CGFloat rightViewWidth = CGRectGetWidth(rightView.frame);
    
    CGRect frame = _selectIndicator.frame;
    frame.origin.x = leftViewPointX + (rightViewPointX - leftViewPointX) * relativeProgress;
    frame.size.width = leftViewWidth + (rightViewWidth - leftViewWidth) * relativeProgress;
    _selectIndicator.frame = frame;
    
    if (_scrollView.scrollEnabled) {
        NSUInteger itemCount = _itemViews.count;
        CGFloat offsetProgress = progress * itemCount / (itemCount - 1);
        CGPoint newOffset = CGPointMake((_scrollView.contentSize.width - CGRectGetWidth(_scrollView.bounds)) * offsetProgress, 0);
        _scrollView.contentOffset = newOffset;
    }
}

- (void)configDelegate:(id<BBPgcTabBarDelegate>)delegate {
    _delegate = delegate;
}

- (UIScrollView *)contentScrollView {
    return _scrollView;
}

#pragma mark - Private

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:_scrollView];
    
    _selectIndicator = [[UIView alloc] init];
    [_scrollView addSubview:_selectIndicator];
}

- (NSArray<UIView<BBPgcTabBarItemProtocol> *> *)_createAndConfigItemViews {
    if (!_delegate) return nil;
    
    NSInteger itemNumer = 0;
    if ([_delegate respondsToSelector:@selector(numberInPgcTabBarView:)]) {
        itemNumer = [_delegate numberInPgcTabBarView:self];
    }
    
    if (itemNumer <= 0) return nil;
    
    NSMutableArray<UIView<BBPgcTabBarItemProtocol> *> *itemViews = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < itemNumer; i++) {
        UIView<BBPgcTabBarItemProtocol> *itemView = nil;
        if ([_delegate respondsToSelector:@selector(pgcTabBarView:itemViewAtIndex:)]) {
            itemView = [_delegate pgcTabBarView:self itemViewAtIndex:i];
        }
        if (!itemView || ![itemView isKindOfClass:UIView.class] || ![itemView conformsToProtocol:@protocol(BBPgcTabBarItemProtocol)]) {
            NSAssert(NO, @"TabBarItem 必须实现BBPgcTabBarItemProtocol协议!");
            itemView = [[BBPgcTabBarItem alloc] init];
        }
        [itemViews addObject:itemView];
        
        /// config item
        __weak typeof(self) weakSelf = self;
        [itemView configActionBlock:^(NSUInteger index, NSUInteger tapsRequiredNumber) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return;
            }
            if (tapsRequiredNumber == 1) {
                [strongSelf itemClickActionWithIndex:index];
            } else if (tapsRequiredNumber == 2) {
                [strongSelf itemDoubleClickActionWithIndex:index];
            }
        }];
        
        BOOL isHighlight = (_selectedIndex == i) ? YES : NO;
        [itemView updateWithIsHighlight:isHighlight];
        
        [itemView configIndex:i];
    }
    return itemViews;
}

- (void)_replaceItemViews:(NSArray<UIView<BBPgcTabBarItemProtocol> *> *)itemViews {
    if (_itemViews.count > 0) {
        for (UIView<BBPgcTabBarItemProtocol> *itemView in _itemViews.copy) {
            if (itemView.superview) {
                [itemView removeFromSuperview];
            }
        }
    }
    if (itemViews.count > 0) {
        for (UIView<BBPgcTabBarItemProtocol> *itemView in itemViews.copy) {
            [_scrollView addSubview:itemView];
        }
    }
    _itemViews = itemViews;
}

- (void)_updateItemsLayout {
    CGFloat itemPointX = 0;
    CGFloat contentSizeWidth = 0;
    for (UIView<BBPgcTabBarItemProtocol> *itemView in _itemViews.copy) {
        CGFloat width = 0;
        if ([itemView respondsToSelector:@selector(itemWidth)]) {
            width = itemView.itemWidth;
        }
        itemView.frame = CGRectMake(itemPointX, 0, width, CGRectGetHeight(self.frame) - self.indicatorHeight);
        contentSizeWidth = itemPointX + width;
        itemPointX = itemPointX + width + _itemSpacing;
    }
    if (contentSizeWidth > CGRectGetWidth(_scrollView.frame)) {
        _scrollView.scrollEnabled = YES;
    } else {
        _scrollView.scrollEnabled = NO;
    }
    _scrollView.contentSize = CGSizeMake(contentSizeWidth, CGRectGetHeight(_scrollView.frame));
}

- (void)_updateSelectIndicatorLayout {
    if (_itemViews.count > 0) {
        UIView<BBPgcTabBarItemProtocol> *currentView = [self getTabBarItemByIndex:_selectedIndex];
        CGFloat width = 0;
        CGFloat pointX = 0;
        if (currentView) {
            width = CGRectGetWidth(currentView.frame);
            pointX = CGRectGetMinX(currentView.frame);
        }
        _selectIndicator.frame = (CGRect) {
            .origin.x = pointX,
            .origin.y = CGRectGetHeight(self.frame) - self.indicatorHeight,
            .size.width = width,
            .size.height = self.indicatorHeight
        };
    }
}

- (void)_switchItemWithIndex:(NSUInteger)index animated:(BOOL)animated completion:(nullable void (^)(void))completion {
    if (_selectedIndex == index) return;
    if (!_itemViews || index >= _itemViews.count) return;
    
    void(^switchItmeBlock)(void) = ^{
        if (self == nil) return;
        self->_selectedIndex = index;
        [self _updateSelectIndicatorLayout];
        [self _updateItemViewHighlight:index];
        [self _updateItemsLayout];
    };
    
    if (animated) {
        [UIView animateWithDuration:kPgcTabBarAnimatedDuration animations:^{
            switchItmeBlock();
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        switchItmeBlock();
        if (completion) {
            completion();
        }
    }
}

- (void)_updateItemViewHighlight:(NSUInteger)index {
    if (!_itemViews || index >= _itemViews.count) return;
    [_itemViews enumerateObjectsUsingBlock:^(UIView<BBPgcTabBarItemProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index != idx) {
            [obj updateWithIsHighlight:NO];
        } else {
            [obj updateWithIsHighlight:YES];
        }
    }];
}

- (nullable UIView<BBPgcTabBarItemProtocol> *)getTabBarItemByIndex:(NSInteger)index {
    if (index >= 0 && _itemViews.count > 0 && index < _itemViews.count) {
        return _itemViews[index];;
    }
    return nil;
}

#pragma mark - Action

- (void)itemClickActionWithIndex:(NSUInteger)index {
    NSUInteger originIdx = self.selectedIndex;
    if (_delegate && [_delegate respondsToSelector:@selector(pgcTabBarView:willClickItemAtOriginIdx:targetIdx:)]) {
        [_delegate pgcTabBarView:self willClickItemAtOriginIdx:originIdx targetIdx:index];
    }
    
    __weak typeof(self) weakSelf = self;
    [self _switchItemWithIndex:index animated:self.indicatorAnimated completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf->_delegate && [strongSelf->_delegate respondsToSelector:@selector(pgcTabBarView:didClickItemAtOriginIdx:targetIdx:)]) {
            [strongSelf->_delegate pgcTabBarView:strongSelf didClickItemAtOriginIdx:originIdx targetIdx:index];
        }
    }];
}

- (void)itemDoubleClickActionWithIndex:(NSUInteger)index {
    if (self.selectedIndex != index) return;
    if (_delegate && [_delegate respondsToSelector:@selector(pgcTabBarView:didDoubleClickItemAtIndex:)]) {
        [_delegate pgcTabBarView:self didDoubleClickItemAtIndex:index];
    }
}

#pragma mark - Setter

- (void)setHorizontalMargin:(CGFloat)horizontalMargin {
    _horizontalMargin = horizontalMargin;
    _scrollView.contentInset = UIEdgeInsetsMake(0, horizontalMargin, 0, horizontalMargin);
}

- (void)setIndicatorHidden:(BOOL)indicatorHidden {
    _indicatorHidden = indicatorHidden;
    self.selectIndicatorView.hidden = indicatorHidden;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    [self _updateSelectIndicatorLayout];
}

@end
