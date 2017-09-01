//
//  UIImage+Extension.h
//  meets-ios
//
//  Created by Mark on 16/6/23.
//  Copyright © 2016年 meets. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)

/**
 *  Rounds a new image in circled shape with diameter
 *
 *  @param diameter The diameter for circle image
 *
 *  @return The circled rounded image.
 */
- (nonnull UIImage *)imageWithCircleDiameter:(CGFloat)diameter;

/**
 *  Rounds a new image in circled shape with border setting
 *
 *  @param diameter The diameter for circle image
 *
 *  @param borderWidth The inset border line width. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @param borderColor The border stroke color. nil means clear color. 
 *
 *  @return The rounded image.
 */
- (nullable UIImage *)imageWithCircleDiameter:(CGFloat)diameter
                                  borderWidth:(CGFloat)borderWidth
                                  borderColor:(nullable UIColor *)borderColor;


/**
 *  Rounds a new image with a given corner size
 *
 *  @param radius The radius of each corner. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @return The rounded image.
 */
- (nonnull UIImage *)imageWithRoundCornerRadius:(CGFloat)radius;

/**
 *  Rounds a new image with a given corner size and border setting
 *
 *  @param radius The radius of each corner. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @param borderWidth The inset border line width. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @param borderColor The border stroke color. nil means clear color.
 *
 *  @return The rounded image.
 */
- (nullable UIImage *)imageWithRoundCornerRadius:(CGFloat)radius
                                     borderWidth:(CGFloat)borderWidth
                                     borderColor:(nullable UIColor *)borderColor;

/**
 *  Rounds a new image with a given corner size and border setting
 *
 *  @param radius The radius of each corner. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @param corners        The corners you want rounded.
 *
 *  @param borderWidth The inset border line width. Values larger than half of the
 *  rectangle's width or height are clamped appropriately to half the width or height.
 *
 *  @param borderColor    The border stroke color. nil means clear color.
 *
 *  @param borderLineJoin The border line join.
 *
 *  @return The rounded image.
 */
- (nullable UIImage *)imageWithRoundCornerRadius:(CGFloat)radius
                                         corners:(UIRectCorner)corners
                                     borderWidth:(CGFloat)borderWidth
                                     borderColor:(nullable UIColor *)borderColor
                                  borderLineJoin:(CGLineJoin)borderLineJoin;

/**
 Returns a new image which is cropped from this image.
 
 @param rect  Image's inner rect.
 
 @return      The new image, or nil if an error occurs.
 */
- (nullable UIImage *)imageByCropToRect:(CGRect)rect;
- (nullable UIImage *)imageByCropToCenterSquare;

/**
 Returns a new image which draw filled color.
 
 @param color  draw filled color
 
 @return      The new image, no nil.
 */
- (UIImage *)mc_imageByFilledColor:(UIColor *)color;

// 中间点平铺调整大小
- (UIImage *)mc_resizable;

// 延展 等比
- (UIImage *)mc_stretchable;

/**
 Returns a new iamge which is gray effect from this image.

 @return gray image
 */
- (UIImage *)grayEffect;

/**
 image中色值替换
 */
- (UIImage*)replaceColorWithColorBlock:(NSUInteger(^)(UInt8 r,UInt8 g,UInt8 b,UInt8 a)) colorblock;

- (UIImage*)replaceColorWithDic:(NSDictionary*)dic;
/**
 X轴方向的反转
 */
- (UIImage*)imageReversaX;
/**
 Y轴方向的反转
 */
- (UIImage*)imageReversaY;

#pragma mark - Class Methods
///=============================================================================
/// UIImage Construct Method
///=============================================================================

/**
 *  Create and return a 1x1 point size image with the given color.
 *
 *  @param color The color you wanted.
 *
 *  @return The image with the given color.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/**
 *  Create and return a 1x1 point size image with the given color.
 *
 *  @param color The color you wanted.
 *
 *  @param size  New image's type.
 *
 *  @return The image with the given color.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  圆形图片创建 拉伸模式:中心点UIImageResizingModeTile平铺
 *
 *  @param radius 圆半径
 *  @param color  背景色
 *  @return 填充图
 */
+ (UIImage *)imageWithRadius:(CGFloat)radius color:(UIColor *)color;

/**
 *  圆形图片创建
 *
 *  @param radius 圆半径
 *  @param color  背景色
 *  @param resizableStretch 是否拉伸时等比例放大
 *         如果yes, 拉伸时等比例放大, 如果no, 中心点UIImageResizingModeTile平铺
 *  @return 填充图
 */

+ (UIImage *)imageWithRadius:(CGFloat)radius color:(UIColor *)color resizableStretch:(BOOL)resizableStretch;

/**
 *  环形图片创建
 *  默认平铺发大
 *  @param radius 半径
 *  @param borderWidth 环大小
 *  @param borderColor 环颜色
 *  @return 填充图
 */

+ (UIImage *)imageWithAnnulusRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/**
 *  圆形图片创建
 *
 *  @param size 图片大小
 *  @param radius 圆角半径
 *  @param color  背景色
 *  @return 填充图
 */
+ (UIImage *)imageWithSize:(CGSize)size radius:(CGFloat)radius color:(nullable UIColor *)color;


/**
 *  矩形圆角图片创建, radius > 0 自动指定中间点为拉伸区域
 *
 *  @param size 图片大小，以radius为主， 可传CGSzieZero
 *  @param radius 半径， 如果 radius > 0, 可通过radius 获取size w = h = radius * 2 正方形
 *          且生成图片支持拉伸 resizable CapInsets 为UIEdgeInsetsMake(radius,radius,radius,radius) UIImageResizingModeTile
 *  @param color  背景色
 *  @param borderWidth 线宽
 *  @param borderColor 线宽颜色
 *  @return 填充图
 */
+ (UIImage *)imageWithSize:(CGSize)size
                    radius:(CGFloat)radius
                     color:(nullable UIColor *)color
               borderWidth:(CGFloat)borderWidth
               borderColor:(nullable UIColor *)borderColor;


/**
 *  创建线条图片
 *
 *  @param size 图片大小, size.with > size.height 横线, 放过来竖线
 *  @param lineWidth 线条大小
 *  @param color 线条颜色
 *  @return 填充图
 */
+ (UIImage *)lineImageWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth size:(CGSize)size;


/**
 *  纯色背景填充图
 *  自动填充图形大小
 *
 *  @param color  背景色
 *  @param radius 圆角半径
 *
 *  @return 填充图
 */
+ (UIImage *)backgroundImageWithColor:(UIColor *)color radius:(CGFloat)radius;

/**
 *  带边框的纯色背景填充图
 *
 *  @param color       背景色
 *  @param radius      圆角半径
 *  @param borderWidth 边框宽度
 *  @param borderColor 边框色
 *
 *  @return 带边框的背景填充图
 */
+ (UIImage *)backgroundImageWithColor:(UIColor *)color
                               radius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;

//
+ (nullable UIImage *)launchImageWithOrientation:(UIDeviceOrientation)orientation;
@end


@interface UIImage (Resize)

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)mc_resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)mc_transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientation;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;
- (UIImage *)rotatedByDegrees:(CGFloat)degrees withScale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
