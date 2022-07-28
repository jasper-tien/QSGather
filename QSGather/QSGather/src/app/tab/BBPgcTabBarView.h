//
//  BBPgcTabBarView.h
//  bilianime
//
//  Created by 清觞 on 2021/4/6.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPgcTabBarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBPgcTabBarView : UIView<BBPgcTabBarProtocol>

@property (nonatomic, assign) CGFloat horizontalMargin;
@property (nonatomic, strong, readonly) UIView *selectIndicatorView;
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, assign, readonly) NSUInteger itemCount;

@end

NS_ASSUME_NONNULL_END
