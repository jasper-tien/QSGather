//
//  BBPgcTabBarItem.h
//  _idx_bbpgcuikit_library_2975233F_ios_min9.0
//
//  Created by 清觞 on 2021/4/6.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPgcTabBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBPgcTabBarItem : UIView<BBPgcTabBarItemProtocol>

@property (nonatomic, assign) BOOL disableTheme;

/// 文案
- (void)configTitle:(nullable NSString *)title subTitle:(nullable NSString *)subTitle;

/// 文案字体
- (void)configTitleFont:(nullable UIFont *)titleFont subTitleFont:(nullable UIFont *)subTitleFont;

/// 文案色值
- (void)configTitleColor:(UIColor *)titleColor isNight:(BOOL)isNight;
- (void)configSubTitleColor:(UIColor *)subTitleColor isNight:(BOOL)isNight;
- (void)configTitleHighlightColor:(UIColor *)titleColor isNight:(BOOL)isNight;
- (void)configSubTitleHighlightColor:(UIColor *)subTitleColor isNight:(BOOL)isNight;

@end

NS_ASSUME_NONNULL_END
