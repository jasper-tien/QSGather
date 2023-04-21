//
//  BBPgcTabController.h
//  _idx_bbpgcuikit_library_961E727E_ios_min10.0
//
//  Created by tianmaotao on 2022/7/26.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BBPgcTabSelectType) {
    BBPgcTabSelectTypeDefault = 0,
    BBPgcTabSelectTypeTap = 1, // 点击tabBar选中
    BBPgcTabSelectTypeScroll = 2, // 滑动选中
    BBPgcTabSelectTypeForce = 3, // 手动选中
};

@class BBPgcTabController;
@protocol BBPgcTabBarItemProtocol;
@protocol BBPgcTabControllerDataSource <NSObject>

@required

- (NSInteger)numberInPgcTabController:(BBPgcTabController *)tabController;
- (UIView<BBPgcTabBarItemProtocol> *)pgcTabController:(BBPgcTabController *)tabController barItemViewAtIndex:(NSUInteger)index;
- (UIViewController *)pgcTabController:(BBPgcTabController *)tabController contentControllerAtIndex:(NSUInteger)index;

@end

@protocol BBPgcTabControllerDelegate <NSObject>

@optional

- (NSUInteger)defaultSelectIndexInPgcTabController:(BBPgcTabController *)tabController;
- (BOOL)indicatorHiddenInPgcTabController:(BBPgcTabController *)tabController;

// Variable height & width support

- (CGFloat)heightForTabBarViewInPgcTabController:(BBPgcTabController *)tabController;
- (CGFloat)tabBarItemSpacingInPgcTabController:(BBPgcTabController *)tabController;
- (CGFloat)indicatorHeightInPgcTabController:(BBPgcTabController *)tabController;
- (UIEdgeInsets)tabBarViewInsetInPgcTabController:(BBPgcTabController *)tabController;
- (UIEdgeInsets)tabBarViewContentInsetInPgcTabController:(BBPgcTabController *)tabController;

// Switch customization

- (void)pgcTabController:(BBPgcTabController *)tabController willSelectTabAtIndex:(NSUInteger)index type:(BBPgcTabSelectType)type;
- (void)pgcTabController:(BBPgcTabController *)tabController didSelectTabAtIndex:(NSUInteger)index type:(BBPgcTabSelectType)type;
- (void)pgcTabController:(BBPgcTabController *)tabController didSelectAgainTabAtIndex:(NSUInteger)index type:(BBPgcTabSelectType)type;
- (void)pgcTabController:(BBPgcTabController *)tabController willDeselectTabAtIndex:(NSUInteger)index type:(BBPgcTabSelectType)type;
- (void)pgcTabController:(BBPgcTabController *)tabController didDeselectTabAtIndex:(NSUInteger)index type:(BBPgcTabSelectType)type;

@end


@protocol BBPgcTabBarProtocol;
@interface BBPgcTabController : UIViewController

@property(nonatomic, weak) id<BBPgcTabControllerDataSource> dataSource;
@property(nonatomic, weak) id<BBPgcTabControllerDelegate> delegate;

// 是否一次性加载所有子ViewController，为YES时，reloadData会一次性加载所有ViewController
@property (nonatomic, readonly) BOOL forceLoad;
@property (nonatomic, readonly) NSUInteger selectIndex;
@property (nonatomic, weak, readonly) UIViewController *selectViewController;

@property (nonatomic, strong, readonly) UIView<BBPgcTabBarProtocol> *tabBarView;
@property (nonatomic, strong, readonly) UIScrollView *pageView;

- (instancetype)initWithForceLoad:(BOOL)forceLoad;
- (instancetype)initWithCustomTabBarView:(UIView<BBPgcTabBarProtocol> *_Nullable)customTabBarView;
- (instancetype)initWithCustomTabBarView:(UIView<BBPgcTabBarProtocol> *_Nullable)customTabBarView forceLoad:(BOOL)forceLoad;

- (void)reloadData;

- (void)scrollTo:(NSUInteger)index animated:(BOOL)animated;

- (UIViewController *_Nullable)contentViewController:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
