//
//  BBPgcTabBarProtocol.h
//  bilianime
//
//  Created by 清觞 on 2021/4/19.
//  Copyright © 2021 哔哩哔哩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PgcTabBarItemActionBlock)(NSUInteger index, NSUInteger tapsRequiredNumber);

@protocol BBPgcTabBarItemProtocol <NSObject>

@required
@property (nonatomic, assign, readonly) NSUInteger itemIndex;
@property (nonatomic, assign, readonly) CGFloat itemWidth;

- (void)configIndex:(NSUInteger)index;
- (void)configCustomWidth:(CGFloat)customWidth;
- (void)configActionBlock:(PgcTabBarItemActionBlock)actionBlock;
- (void)updateWithIsHighlight:(BOOL)isHighlight;
@optional
- (void)setupMaxTextLengthLimit:(NSUInteger)limit; // 最多显示limit个文字  +  ...

@end


@protocol BBPgcTabBarDelegate <NSObject>

@required
- (NSInteger)numberInPgcTabBarView:(id)view;
- (UIView<BBPgcTabBarItemProtocol> *)pgcTabBarView:(id)view itemViewAtIndex:(NSUInteger)index;

@optional
- (void)pgcTabBarView:(id)view willClickItemAtOriginIdx:(NSUInteger)originIdx targetIdx:(NSUInteger)targetIdx;
- (void)pgcTabBarView:(id)view didClickItemAtOriginIdx:(NSUInteger)originIdx targetIdx:(NSUInteger)targetIdx;
- (void)pgcTabBarView:(id)view didDoubleClickItemAtIndex:(NSUInteger)index;

@end


@protocol BBPgcTabBarProtocol <NSObject>

@required

@property (nonatomic, assign) BOOL indicatorHidden;
@property (nonatomic, assign) BOOL indicatorAnimated;
@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, strong, readonly) UIView *selectIndicatorView;
@property (nonatomic, assign, readonly) UIScrollView *contentScrollView;

- (void)reloadData;
- (void)selectToIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)configDelegate:(id<BBPgcTabBarDelegate>)delegate;
- (void)updateWithProgress:(CGFloat)progress relativeProgress:(CGFloat)relativeProgress leftIndex:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex;

@end

NS_ASSUME_NONNULL_END
