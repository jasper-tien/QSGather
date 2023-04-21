//
//  BBPgcTabController.m
//  _idx_bbpgcuikit_library_961E727E_ios_min10.0
//
//  Created by tianmaotao on 2022/7/26.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import "BBPgcTabController.h"
#import "BBPgcTabBarProtocol.h"
#import "BBPgcTabBarItem.h"
#import "BBPgcTabBarView.h"
#import <objc/runtime.h>
#import "UIView+QSFrame.h"

typedef NS_ENUM(NSInteger, PGCVCStatus) {
    PGCVCStatusViewUnknown = 0,
    PGCVCStatusViewWillAppear,
    PGCVCStatusViewDidAppear,
    PGCVCStatusViewWillDisappear,
    PGCVCStatusViewDidDisappear,
};

static char pgc_vc_status;
static CGFloat kPgcTabControllerAnimationDuration = 0.25;
static CGFloat kPgcTabBarViewAreaHeightDefault = 44.f;

@interface BBPgcTabController ()<UIScrollViewDelegate, BBPgcTabBarDelegate>

@property (nonatomic, strong) UIScrollView *pageView;
@property (nonatomic, strong) UIView<BBPgcTabBarProtocol> *tabBarView;
@property (nonatomic, strong, nullable) UIView<BBPgcTabBarProtocol> *customTabBarView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIViewController *> *loadedViewControllers;
@property (nonatomic, assign) NSInteger numbersOfViewController;
@property (nonatomic, weak) UIViewController *selectViewController;

@property (nonatomic, assign) NSUInteger selectIndex;
@property (nonatomic, assign) BOOL forceLoad;
@property (nonatomic, assign) BOOL transition;
@property (nonatomic, assign) PGCVCStatus tabVCStatus;

@end

@implementation BBPgcTabController

#pragma mark - init

- (instancetype)init {
    return [self initWithCustomTabBarView:nil forceLoad:NO];
}

- (instancetype)initWithForceLoad:(BOOL)forceLoad {
    return [self initWithCustomTabBarView:nil forceLoad:forceLoad];
}

- (instancetype)initWithCustomTabBarView:(UIView<BBPgcTabBarProtocol> *_Nullable)customTabBarView {
    return [self initWithCustomTabBarView:customTabBarView forceLoad:NO];
}

- (instancetype)initWithCustomTabBarView:(UIView<BBPgcTabBarProtocol> *_Nullable)customTabBarView forceLoad:(BOOL)forceLoad {
    if (self = [super init]) {
        _customTabBarView = customTabBarView;
        _forceLoad = forceLoad;
    }
    return self;
}

#pragma mark - override methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabVCStatus = PGCVCStatusViewWillAppear;
    [self _updateStatus:PGCVCStatusViewWillAppear controller:self.selectViewController animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabVCStatus = PGCVCStatusViewDidAppear;
    [self _updateStatus:PGCVCStatusViewDidAppear controller:self.selectViewController animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabVCStatus = PGCVCStatusViewWillDisappear;
    [self _updateStatus:PGCVCStatusViewWillDisappear controller:self.selectViewController animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tabVCStatus = PGCVCStatusViewDidDisappear;
    [self _updateStatus:PGCVCStatusViewDidDisappear controller:self.selectViewController animated:animated];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat tabBarViewAreaHeight = kPgcTabBarViewAreaHeightDefault;
    UIEdgeInsets tabBarViewInset = UIEdgeInsetsZero;
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(heightForTabBarViewInPgcTabController:)]) {
            tabBarViewAreaHeight = [self.delegate heightForTabBarViewInPgcTabController:self];
        }
        if ([self.delegate respondsToSelector:@selector(tabBarViewInsetInPgcTabController:)]) {
            tabBarViewInset = [self.delegate tabBarViewInsetInPgcTabController:self];
        }
    }
    
    self.tabBarView.frame = (CGRect){
        .origin.x = tabBarViewInset.left,
        .origin.y = tabBarViewInset.top,
        .size.width = MAX(0, self.view.viewWidth - tabBarViewInset.left - tabBarViewInset.right),
        .size.height = MAX(0, tabBarViewAreaHeight - tabBarViewInset.top - tabBarViewInset.bottom),
    };
    self.pageView.frame = (CGRect){
        .origin.y = tabBarViewAreaHeight,
        .size.width = self.view.viewWidth,
        .size.height = MAX(0, self.view.viewHeight - tabBarViewAreaHeight),
    };
    self.pageView.contentSize = CGSizeMake(self.view.viewWidth * self.numbersOfViewController, 0);
    [self.pageView setContentOffset:CGPointMake(self.pageView.viewWidth * self.selectIndex, 0)];
    if (self.loadedViewControllers.count > 0) {
        [self.loadedViewControllers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIViewController * _Nonnull obj, BOOL * _Nonnull stop) {
            NSInteger index = [key integerValue];
            obj.view.frame = CGRectMake(self.pageView.viewWidth * index, 0, self.pageView.viewWidth, self.pageView.viewHeight);
        }];
    }
}

#pragma mark - public methods

- (void)reloadData {
    [self _reloadData:NO];
}

- (void)scrollTo:(NSUInteger)index animated:(BOOL)animated {
    if (index == self.selectIndex || index >= self.numbersOfViewController) return;
    [self _selectToIndex:index animated:animated selectType:BBPgcTabSelectTypeForce];
    [self.tabBarView selectToIndex:index animated:animated];
}

- (UIViewController *_Nullable)contentViewController:(NSUInteger)index {
    return self.loadedViewControllers[@(index).stringValue];
}

#pragma mark - private methods

- (void)setupSubviews {
    if (_customTabBarView != nil && [_customTabBarView conformsToProtocol:@protocol(BBPgcTabBarProtocol)]) {
        _tabBarView = _customTabBarView;
    } else {
        _tabBarView = [[BBPgcTabBarView alloc] init];
        _tabBarView.selectIndicatorView.backgroundColor = [UIColor systemPinkColor];
        [_tabBarView configDelegate:self];
    }
    [self.view addSubview:_tabBarView];
    
    _pageView = [UIScrollView new];
    _pageView.backgroundColor = [UIColor clearColor];
    _pageView.showsVerticalScrollIndicator = NO;
    _pageView.showsHorizontalScrollIndicator = NO;
    _pageView.pagingEnabled = YES;
    _pageView.bounces = NO;
    _pageView.delegate = self;
    _pageView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        _pageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_pageView];
}

- (void)_reloadData:(BOOL)isForce {
    if (self.dataSource == nil) {
        return;
    }
    
    if (![self.dataSource respondsToSelector:@selector(numberInPgcTabController:)]) {
        return;
    }
    self.numbersOfViewController = [self.dataSource numberInPgcTabController:self];
    self.pageView.contentSize = CGSizeMake(self.view.viewWidth * self.numbersOfViewController, 0);
    
    NSUInteger selectIndex = [self _defatultSelectIndex];
    selectIndex = MAX(0, selectIndex);
    selectIndex = MIN(self.numbersOfViewController - 1, selectIndex);
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(tabBarItemSpacingInPgcTabController:)] && [self.tabBarView respondsToSelector:@selector(setItemSpacing:)]) {
            [self.tabBarView setItemSpacing:[self.delegate tabBarItemSpacingInPgcTabController:self]];
        }
        if ([self.delegate respondsToSelector:@selector(indicatorHeightInPgcTabController:)] && [self.tabBarView respondsToSelector:@selector(setIndicatorHeight:)]) {
            [self.tabBarView setIndicatorHeight:[self.delegate indicatorHeightInPgcTabController:self]];
        }
        if ([self.delegate respondsToSelector:@selector(indicatorHiddenInPgcTabController:)] && [self.tabBarView respondsToSelector:@selector(setIndicatorHidden:)]) {
            [self.tabBarView setIndicatorHidden:[self.delegate indicatorHiddenInPgcTabController:self]];
        }
        if ([self.delegate respondsToSelector:@selector(tabBarViewContentInsetInPgcTabController:)] && [self.tabBarView respondsToSelector:@selector(contentScrollView)]) {
            self.tabBarView.contentScrollView.contentInset = [self.delegate tabBarViewContentInsetInPgcTabController:self];
        }
    }
    
    [self.tabBarView reloadData];
    [self.tabBarView selectToIndex:selectIndex animated:NO];
    
    UIViewController *selectVC = [self.dataSource pgcTabController:self contentControllerAtIndex:selectIndex];
    BOOL ignore = (selectVC == self.selectViewController) && (!isForce);
    if (self.loadedViewControllers.count > 0) {
        for (UIViewController *subVC in self.loadedViewControllers.allValues.copy) {
            if (!ignore && subVC == self.selectViewController) {
                [self _updateStatus:PGCVCStatusViewWillDisappear controller:subVC animated:NO];
            }
            
            [subVC.view removeFromSuperview];
            [subVC removeFromParentViewController];
            
            if (!ignore && subVC == self.selectViewController) {
                [self _updateStatus:PGCVCStatusViewDidDisappear controller:subVC animated:NO];
            }
        }
    }
    
    if (self.forceLoad) {
        // 强制加载所有ViewController
        for (int i = 0; i < self.numbersOfViewController; i++) {
            [self _loadControllerWithIndex:i];
        }
    }
    
    // 切到默认选中tab
    [self _selectToIndex:selectIndex animated:NO selectType:BBPgcTabSelectTypeDefault];
}

- (void)_selectToIndex:(NSUInteger)index animated:(BOOL)animated selectType:(BBPgcTabSelectType)selectType {
    if (index < 0 || index >= self.numbersOfViewController) {
        return;
    }
    
    UIViewController *lastSelectVC = self.selectViewController;
    UIViewController *selectVC = [self _loadControllerWithIndex:index];
    
    if (self.tabVCStatus < PGCVCStatusViewWillDisappear) {
        [self _updateStatus:PGCVCStatusViewWillDisappear controller:lastSelectVC animated:NO];
        if (self.tabVCStatus >= PGCVCStatusViewWillAppear) {
            [self _updateStatus:PGCVCStatusViewWillAppear controller:selectVC animated:NO];
        }
    }
    
    NSUInteger oldSelectIndex = self.selectIndex;
    self.selectIndex = index;
    self.selectViewController = selectVC;
    
    if (self.transition) {
        [self.pageView.layer removeAllAnimations];
    }
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(pgcTabController:willDeselectTabAtIndex:type:)]) {
            [self.delegate pgcTabController:self willDeselectTabAtIndex:oldSelectIndex type:selectType];
        }
        if ([self.delegate respondsToSelector:@selector(pgcTabController:willSelectTabAtIndex:type:)]) {
            [self.delegate pgcTabController:self willSelectTabAtIndex:index type:selectType];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_block_t completionBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        strongSelf.transition = NO;
        if (self.tabVCStatus < PGCVCStatusViewDidDisappear) {
            [strongSelf _updateStatus:PGCVCStatusViewDidDisappear controller:lastSelectVC animated:NO];
            if (self.tabVCStatus >= PGCVCStatusViewDidAppear) {
                [strongSelf _updateStatus:PGCVCStatusViewDidAppear controller:selectVC animated:NO];
            }
        }
        if (strongSelf.delegate != nil) {
            if ([strongSelf.delegate respondsToSelector:@selector(pgcTabController:didDeselectTabAtIndex:type:)]) {
                [strongSelf.delegate pgcTabController:strongSelf didDeselectTabAtIndex:oldSelectIndex type:selectType];
            }
            if ([strongSelf.delegate respondsToSelector:@selector(pgcTabController:didSelectTabAtIndex:type:)]) {
                [strongSelf.delegate pgcTabController:strongSelf didSelectTabAtIndex:index type:selectType];
            }
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:kPgcTabControllerAnimationDuration animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.transition = YES;
            [strongSelf.pageView setContentOffset:CGPointMake(strongSelf.pageView.viewWidth * index, 0)];
        } completion:^(BOOL finished) {
            if (completionBlock != nil) {
                completionBlock();
            }
        }];
    } else {
        [self.pageView setContentOffset:CGPointMake(self.pageView.viewWidth * index, 0)];
        if (completionBlock != nil) {
            completionBlock();
        }
    }
}

- (UIViewController *_Nullable)_loadControllerWithIndex:(NSUInteger)index {
    if (index < self.numbersOfViewController && self.dataSource != nil && [self.dataSource respondsToSelector:@selector(pgcTabController:contentControllerAtIndex:)]) {
        UIViewController *vc = [self.dataSource pgcTabController:self contentControllerAtIndex:index];
        [self _insertController:vc toIndex:index];
        return vc;
    }
    return nil;
}

- (void)_insertController:(UIViewController *)controller toIndex:(NSUInteger)index {
    if (controller && index >= 0 && index < self.numbersOfViewController) {
        self.loadedViewControllers[@(index).stringValue] = controller;
        controller.view.frame = CGRectMake(self.pageView.viewWidth * index, 0, self.pageView.viewWidth, self.pageView.viewHeight);
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:controller];
        [self.pageView addSubview:controller.view];
    }
}

- (NSUInteger)_defatultSelectIndex {
    NSUInteger defatultSelectIndex = 0;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(defaultSelectIndexInPgcTabController:)]) {
        defatultSelectIndex = [self.delegate defaultSelectIndexInPgcTabController:self];
    }
    return defatultSelectIndex;
}

- (void)_updateTabBarWithContentOffsetX:(CGFloat)contentOffsetX {
    CGFloat contentSizeWidth = self.pageView.contentSize.width;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    if (contentSizeWidth < 0.001 || contentOffsetX < 0.001 || width < 0.001) {
        return;
    }
    
    CGFloat currentIndex = contentOffsetX / width;
    NSInteger leftIndex = floor(currentIndex);
    NSInteger rightIndex = ceil(currentIndex);
    
    CGFloat currentPintx = contentOffsetX;
    CGFloat leftPointX = leftIndex * width;
    CGFloat rightPointX = rightIndex * width;
    
    CGFloat unitRelativePointX = rightPointX - leftPointX;
    CGFloat currentRelativePointX = currentPintx - leftPointX;
    
    CGFloat relativeProgress = 0;
    if (unitRelativePointX > 0 || unitRelativePointX < 0) {
        relativeProgress = currentRelativePointX / unitRelativePointX;
    }
    CGFloat progress = contentOffsetX / contentSizeWidth;
    [self.tabBarView updateWithProgress:progress relativeProgress:relativeProgress leftIndex:leftIndex rightIndex:rightIndex];
}

- (void)_updateStatus:(PGCVCStatus)status controller:(UIViewController *)controller animated:(BOOL)animated {
    if (controller != nil && [objc_getAssociatedObject(controller, &pgc_vc_status) integerValue] != status) {
        objc_setAssociatedObject(controller, &pgc_vc_status, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        switch (status) {
            case PGCVCStatusViewWillAppear: {
                [controller beginAppearanceTransition:YES animated:animated];
                break;
            }
            case PGCVCStatusViewWillDisappear: {
                [controller beginAppearanceTransition:NO animated:animated];
                break;
            }
            case PGCVCStatusViewDidAppear:
            case PGCVCStatusViewDidDisappear: {
                [controller endAppearanceTransition];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - BBPgcTabBarDelegate

- (NSInteger)numberInPgcTabBarView:(id)view {
    return self.numbersOfViewController;
}

- (UIView<BBPgcTabBarItemProtocol> *)pgcTabBarView:(id)view itemViewAtIndex:(NSUInteger)index {
    if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(pgcTabController:barItemViewAtIndex:)]) {
        return [self.dataSource pgcTabController:self barItemViewAtIndex:index];
    }
    return [BBPgcTabBarItem new];
}

- (void)pgcTabBarView:(id)view didClickItemAtOriginIdx:(NSUInteger)originIdx targetIdx:(NSUInteger)targetIdx {
    [self _selectToIndex:targetIdx animated:YES selectType:BBPgcTabSelectTypeTap];
}

- (void)pgcTabBarView:(id)view didDoubleClickItemAtIndex:(NSUInteger)index {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(pgcTabController:didSelectAgainTabAtIndex:type:)]) {
        [self.delegate pgcTabController:self didSelectAgainTabAtIndex:index type:BBPgcTabSelectTypeTap];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self _updateTabBarWithContentOffsetX:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!CGRectGetWidth(scrollView.bounds)) return;
    NSUInteger selectedIndex = (NSUInteger)(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
    [self.tabBarView selectToIndex:selectedIndex animated:NO];
    [self _selectToIndex:selectedIndex animated:NO selectType:BBPgcTabSelectTypeScroll];
}

#pragma mark - setter & getter

- (NSMutableDictionary<NSString *, UIViewController *> *)loadedViewControllers {
    if (!_loadedViewControllers) {
        _loadedViewControllers = @{}.mutableCopy;
    }
    return _loadedViewControllers;
}

@end
