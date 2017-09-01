//
//  CGUtilities.h
//  Anniversary
//
//  Created by 小希 on 2017/8/31.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

extern UIApplication * _Nullable AIQSharedApplication();

// Calculate once
extern CGSize AIQScreenSize();
extern CGFloat AIQScreenScale();
extern CGFloat AIQStatusBarHeight();

// Accurate to the decimal point after the n bit, n is determinded by scale
// Convert pixel to point.
static inline CGFloat PointFromPixel(CGFloat value) {
    return value / AIQScreenScale();
}

// floor point value for pixel-aligned
static inline CGFloat PointPixelFloor(CGFloat value) {
    CGFloat scale = AIQScreenScale();
    return floor(value * scale) / scale;
}

// ceil point value for pixel-aligned
static inline CGFloat PointPixelCeil(CGFloat value) {
    CGFloat scale = AIQScreenScale();
    return ceil(value * scale) / scale;
}

// round point value for pixel-aligned
static inline CGFloat PointPixelRound(CGFloat value) {
    CGFloat scale = AIQScreenScale();
    return round(value * scale) / scale;
}

// adapter based on iPhone6
static inline CGFloat PointAdapt(CGFloat value) {
    return PointPixelFloor(value * AIQScreenSize().width / 375.f);
}

// main screen's scale
#ifndef kScreenScale
#define kScreenScale AIQScreenScale()
#endif

// main screen's width (portrait)
#ifndef kScreenWidth
#define kScreenWidth AIQScreenSize().width
#endif

// main screen's height (portrait)
#ifndef kScreenHeight
#define kScreenHeight AIQScreenSize().height
#endif

#ifndef kStatusBarHeight
#define kStatusBarHeight AIQStatusBarHeight()
#endif

#ifndef kNavigationBarHeight
#define kNavigationBarHeight    44
#endif

#ifndef kTabbarHeight
#define kTabbarHeight    49
#endif

#ifndef kSearchBarHeight
#define kSearchBarHeight    44
#endif


NS_ASSUME_NONNULL_END

