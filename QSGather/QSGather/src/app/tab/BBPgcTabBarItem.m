//
//  BBPgcTabBarItem.m
//  _idx_bbpgcuikit_library_2975233F_ios_min9.0
//
//  Created by 清觞 on 2021/4/6.
//  Copyright © 2021 Bilibili. All rights reserved.
//

#import "BBPgcTabBarItem.h"
#import "UIView+QSFrame.h"

#define kPgcTabBarItemSingleTap 1
#define kPgcTabBarItemDoubleTap 2

@interface BBPgcTabBarItemElement : NSObject
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *subTitleColor;

@property (nonatomic, strong) UIColor *titleSelectColor;
@property (nonatomic, strong) UIColor *subTitleSelectColor;

@property (nonatomic, strong) UIColor *titleNightColor;
@property (nonatomic, strong) UIColor *subTitleNightColor;

@property (nonatomic, strong) UIColor *titleNightSelectColor;
@property (nonatomic, strong) UIColor *subTitleNightSelectColor;
@end

@implementation BBPgcTabBarItemElement

@end


@interface BBPgcTabBarItem() {
    UILabel *_contentLabel;
    NSUInteger _itemIndex;
    CGFloat _customWidth;
    CGFloat _autoWidth;
    BOOL _hasWidth;
    BOOL _isHighlight;
    NSMutableAttributedString *_titleAttriStr;
    NSMutableAttributedString *_subTitleAttriStr;
    BBPgcTabBarItemElement *_titleElement;
    BBPgcTabBarItemElement *_subTitleElement;
    PgcTabBarItemActionBlock _actionBlock;
}
@end

@implementation BBPgcTabBarItem

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupConfig];
        [self themeChanged];
    }
    return self;
}

#pragma mark - private

- (void)setupConfig {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    [self addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_contentLabel];
    
    _titleElement = [[BBPgcTabBarItemElement alloc] init];
    _subTitleElement = [[BBPgcTabBarItemElement alloc] init];
}

- (BOOL)isDarkTheme {
    return NO;
}

- (UIColor *)_currentTextColor:(BOOL)isTitle {
    BBPgcTabBarItemElement *textElement = isTitle ? _titleElement : _subTitleElement;
    BOOL isValidDarkTheme = [self isDarkTheme] && !_disableTheme;
    if (_isHighlight) {
        if (isValidDarkTheme) {
            // 高亮夜间模式
            if (textElement.titleNightSelectColor) {
                return textElement.titleNightSelectColor;
            }
        } else {
            // 高亮白色主题
            if (textElement.titleSelectColor) {
                return textElement.titleSelectColor;
            }
        }
        return [UIColor systemPinkColor];
    } else {
        if (isValidDarkTheme) {
            // 未选中夜间模式
            if (textElement.titleNightColor) {
                return textElement.titleNightColor;
            }
        } else {
            // 未选中白色主题
            if (textElement.titleColor) {
                return textElement.titleColor;
            }
        }
        return [UIColor blackColor];
    }
    return [UIColor blackColor];
}

- (NSMutableAttributedString *)_getContentTitle {
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] init];
    if (_titleAttriStr) {
        NSMutableDictionary *attributes = @{}.mutableCopy;
        attributes[NSFontAttributeName] = _titleElement.font ?: [UIFont systemFontOfSize:13];
        attributes[NSForegroundColorAttributeName] = [self _currentTextColor:YES];
        [_titleAttriStr setAttributes:attributes range:NSMakeRange(0, _titleAttriStr.length)];
        [attributedTitle appendAttributedString:_titleAttriStr];
    }
    if (_subTitleAttriStr) {
        NSMutableDictionary *attributes = @{}.mutableCopy;
        attributes[NSFontAttributeName] = _titleElement.font ?: [UIFont systemFontOfSize:10];
        attributes[NSForegroundColorAttributeName] = [self _currentTextColor:NO];
        [_subTitleAttriStr setAttributes:attributes range:NSMakeRange(0, _subTitleAttriStr.length)];
        [attributedTitle appendAttributedString:_subTitleAttriStr];
    }
    return attributedTitle;
}

- (CGFloat)_getContentTitleWidth {
    if (_customWidth > 0) {
        return _customWidth;
    }
    if (_hasWidth) {
        return _autoWidth;
    }
    _hasWidth = YES;
    NSAttributedString *attributedText = [self _getContentTitle];
    if (!attributedText) {
        _autoWidth = 0;
        return 0;
    }
    _autoWidth = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20.f) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.width;
    return _autoWidth;
}

#pragma mark - overriden

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentLabel.frame = self.bounds;
}

#pragma mark - public

- (void)configTitle:(nullable NSString *)title subTitle:(nullable NSString *)subTitle {
    _hasWidth = NO;
    BOOL hasTitle = NO;
    if (title && title.length > 0) {
        hasTitle = YES;
        _titleAttriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", title ?: @""]];
    } else {
        _titleAttriStr = nil;
    }
    if (subTitle && subTitle.length > 0) {
        NSString *blankStr = hasTitle ? @" " : @"";
        _subTitleAttriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", blankStr, subTitle ?: @""]];
    } else {
        _subTitleAttriStr = nil;
    }
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

- (void)configTitleFont:(nullable UIFont *)titleFont subTitleFont:(nullable UIFont *)subTitleFont {
    _hasWidth = NO;
    _titleElement.font = titleFont ?: [UIFont systemFontOfSize:13];
    _subTitleElement.font = subTitleFont ?: [UIFont systemFontOfSize:10];
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

- (void)configTitleColor:(UIColor *)titleColor isNight:(BOOL)isNight {
    if (isNight) {
        _titleElement.titleNightColor = titleColor;
    } else {
        _titleElement.titleColor = titleColor;
    }
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

- (void)configSubTitleColor:(UIColor *)subTitleColor isNight:(BOOL)isNight {
    if (isNight) {
        _subTitleElement.subTitleNightColor = subTitleColor;
    } else {
        _subTitleElement.subTitleColor = subTitleColor;
    }
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

- (void)configTitleHighlightColor:(UIColor *)titleColor isNight:(BOOL)isNight {
    if (isNight) {
        _titleElement.titleNightSelectColor = titleColor;
    } else {
        _titleElement.titleSelectColor = titleColor;
    }
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

- (void)configSubTitleHighlightColor:(UIColor *)subTitleColor isNight:(BOOL)isNight {
    if (isNight) {
        _subTitleElement.subTitleNightSelectColor = subTitleColor;
    } else {
        _subTitleElement.subTitleSelectColor = subTitleColor;
    }
    _contentLabel.attributedText = [self _getContentTitle];
    [self setNeedsLayout];
}

#pragma mark - BBPgcTabBarItemProtocol

- (void)configIndex:(NSUInteger)index {
    _itemIndex = index;
}

- (void)configCustomWidth:(CGFloat)customWidth {
    _customWidth = customWidth;
}

- (void)configActionBlock:(PgcTabBarItemActionBlock)actionBlock {
    _actionBlock = actionBlock;
}

- (void)updateWithIsHighlight:(BOOL)isHighlight {
    if (_isHighlight == isHighlight) return;
    _isHighlight = isHighlight;
    [self setNeedsLayout];
}

- (NSUInteger)itemIndex {
    return _itemIndex;
}

- (CGFloat)itemWidth {
    return [self _getContentTitleWidth];
}

- (void)setDisableTheme:(BOOL)disableTheme {
    _disableTheme = disableTheme;
    [self setNeedsLayout];
}

#pragma mark - Event

- (void)clickAction:(UITapGestureRecognizer *)tap {
    if (_actionBlock) {
        _actionBlock(_itemIndex, ((tap.numberOfTapsRequired == 2) ? kPgcTabBarItemDoubleTap : kPgcTabBarItemSingleTap));
    }
}

#pragma mark - Theme

- (void)themeChanged {
    _contentLabel.attributedText = [self _getContentTitle];
}

@end
