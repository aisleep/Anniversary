//
//  UIImage+Extension.m
//  meets-ios
//
//  Created by Mark on 16/6/23.
//  Copyright © 2016年 meets. All rights reserved.
//

#import "UIImage+Extension.h"
#import <Accelerate/Accelerate.h>
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>
#import "UIColor+Extension.h"

static NSString *alpaInfoKey;

@implementation UIImage (Extension)

- (UIImage *)imageWithCircleDiameter:(CGFloat)diameter {
    return [self imageWithCircleDiameter:diameter borderWidth:0 borderColor:nil];
}

- (UIImage *)imageWithCircleDiameter:(CGFloat)diameter
                         borderWidth:(CGFloat)borderWidth
                         borderColor:(UIColor *)borderColor {
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    if (borderWidth < diameter / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, borderWidth, borderWidth)];
        [path closePath];
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
        
        if (borderColor && borderWidth > 0) {
            CGFloat strokeInset = (floor(borderWidth * kScreenScale) + 0.5) / kScreenScale;
            CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
            CGFloat strokeRadius = (diameter / 2.f) > kScreenScale / 2 ? (diameter / 2.f) - kScreenScale / 2 : 0;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
            [path closePath];
            
            path.lineWidth = borderWidth;
            path.lineJoinStyle = kCGLineJoinMiter;
            [borderColor setStroke];
            [path stroke];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithRoundCornerRadius:(CGFloat)radius {
    return [self imageWithRoundCornerRadius:radius borderWidth:0 borderColor:nil];
}

- (UIImage *)imageWithRoundCornerRadius:(CGFloat)radius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor {
    return [self imageWithRoundCornerRadius:radius
                                    corners:UIRectCornerAllCorners
                                borderWidth:borderWidth
                                borderColor:borderColor
                             borderLineJoin:kCGLineJoinMiter];
}

- (UIImage *)imageWithRoundCornerRadius:(CGFloat)radius
                                corners:(UIRectCorner)corners
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                         borderLineJoin:(CGLineJoin)borderLineJoin {
    
    if (corners != UIRectCornerAllCorners) {
        UIRectCorner tmp = 0;
        if (corners & UIRectCornerTopLeft) tmp |= UIRectCornerBottomLeft;
        if (corners & UIRectCornerTopRight) tmp |= UIRectCornerBottomRight;
        if (corners & UIRectCornerBottomLeft) tmp |= UIRectCornerTopLeft;
        if (corners & UIRectCornerBottomRight) tmp |= UIRectCornerTopRight;
        corners = tmp;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGFloat minSize = MIN(self.size.width, self.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];
        
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
        
        if (borderColor && borderWidth > 0) {
            CGFloat strokeInset = (floor(borderWidth * kScreenScale) + 0.5) / kScreenScale;
            CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
            CGFloat strokeRadius = radius > kScreenScale / 2 ? radius - kScreenScale / 2 : 0;
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
            [path closePath];
            
            path.lineWidth = borderWidth;
            path.lineJoinStyle = borderLineJoin;
            [borderColor setStroke];
            [path stroke];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByCropToCenterSquare {
    double cropLength;
    
    cropLength = MIN(self.size.width, self.size.height);
    
    double x = self.size.width / 2.0 - cropLength / 2.0;
    double y = self.size.height / 2.0 - cropLength / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, cropLength, cropLength);
    
    return [self imageByCropToRect:cropRect];
}

- (UIImage *)imageByCropToRect:(CGRect)rect {
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)grayEffect {
    int bitmapInfo = CGImageGetAlphaInfo(self.CGImage);//这里取出图片自己的alpha配置值
    size_t bits = CGImageGetBitsPerComponent(self.CGImage);//用图片自己的bits
//    int width = self.size.width;
//    int height = self.size.height;
    size_t width = CGImageGetWidth(self.CGImage);//这里要用像素的宽度
    size_t height = CGImageGetHeight(self.CGImage);//这里要用像素的高度
    size_t bitsPerRow = CGImageGetBytesPerRow(self.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();//用灰色色值空间
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  bits,      // bits per component
                                                  bitsPerRow,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef cgGrayImage = CGBitmapContextCreateImage(context);
    if (cgGrayImage == NULL) {
        CGContextRelease(context);
        return nil;
    }
    UIImage *grayImage = [UIImage imageWithCGImage:cgGrayImage
                                             scale:self.scale//用图片自己的放缩率
                                       orientation:self.imageOrientation];
    CGImageRelease(cgGrayImage);
    CGContextRelease(context);
    return grayImage;
}

- (UIImage*)operationImageWithBlock:(void(^)(UInt8*pixelBuf,size_t width,size_t height,size_t bits,size_t bitsPerRow))block{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGImageRef inImage = self.CGImage;
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    size_t bits = CGImageGetBitsPerComponent(inImage);
    size_t bitsPerRow = CGImageGetBytesPerRow(inImage);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(inImage);
    int alphaInfo = CGImageGetAlphaInfo(inImage);
    
    if (alphaInfo != kCGImageAlphaPremultipliedLast &&
        alphaInfo != kCGImageAlphaNoneSkipLast) {
        if (alphaInfo == kCGImageAlphaNone ||
            alphaInfo == kCGImageAlphaNoneSkipFirst) {
            alphaInfo = kCGImageAlphaNoneSkipLast;
        }else {
            alphaInfo = kCGImageAlphaPremultipliedLast;
        }
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     bits,
                                                     bitsPerRow,
                                                     colorSpace,
                                                     alphaInfo);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), inImage);
        inImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }else {
        CGImageRetain(inImage);
    }
    
    CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    NSUInteger length = CFDataGetLength(m_DataRef);
    CFMutableDataRef m_DataRefEdit = CFDataCreateMutableCopy(NULL,length,m_DataRef);
    CFRelease(m_DataRef);
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetMutableBytePtr(m_DataRefEdit);
    
    block(m_PixelBuf,width,height,bits,bitsPerRow);
    
    CGImageRelease(inImage);
    CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
                                             width,
                                             height,
                                             bits,
                                             bitsPerRow,
                                             colorSpace,
                                             alphaInfo
                                             );
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef
                                              scale:self.scale
                                        orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CFRelease(m_DataRefEdit);
    return finalImage;
}

- (UIImage*)replaceColorWithDic:(NSDictionary*)dic{
    return [self operationImageWithBlock:^(UInt8 *pixelBuf, size_t width, size_t height, size_t bits, size_t bitsPerRow) {
        size_t unit = bitsPerRow/width;
        size_t singleColorSize = bits/8;//8对应UInt8
        if(unit != singleColorSize * 4 && singleColorSize == 1) return;//只处理#RGBA 且色值范围0-255;
        for (size_t row = 0; row < height; row ++) {
            for (size_t cell = 0; cell < width; cell ++) {
                size_t i = (row * width + cell)*unit;
                NSUInteger r = i;
                NSUInteger g = i+1;
                NSUInteger b = i+2;
                NSUInteger a = i+3;
                
                UInt8 red     = pixelBuf[r];
                UInt8 green   = pixelBuf[g];
                UInt8 blue    = pixelBuf[b];
                UInt8 alpha   = pixelBuf[a];
                
                NSString* hexString = [NSString stringWithFormat:@"%02x%02x%02x",red,green,blue];
                NSString* hexStringWithAlpha = [NSString stringWithFormat:@"%02x%02x%02x%02x",red,green,blue,alpha];
                if(dic[hexStringWithAlpha] || dic[hexString]){
                    UIColor *hexColor = [UIColor colorWithHexString:dic[hexStringWithAlpha]];
                    uint32_t color = [hexColor rgbaValue];
                    pixelBuf[r] = (color >> 24) & 0xff;
                    pixelBuf[g] = (color >> 16) & 0xff;
                    pixelBuf[b] = (color >> 8) & 0xff;
                    pixelBuf[a] = color & 0xff;
                }
            }
        }
    }];
}


- (UIImage*)replaceColorWithColorBlock:(NSUInteger(^)(UInt8 r,UInt8 g,UInt8 b,UInt8 a)) colorblock{
    return [self operationImageWithBlock:^(UInt8 *pixelBuf, size_t width, size_t height, size_t bits, size_t bitsPerRow) {
        size_t unit = bitsPerRow/width;
        size_t singleColorSize = bits/8;//8对应UInt8
        if(unit != singleColorSize * 4 && singleColorSize == 1) return;//只处理#RGBA 且色值范围0-255;
        for (size_t row = 0; row < height; row ++) {
            for (size_t cell = 0; cell < width; cell ++) {
                size_t i = (row * width + cell)*unit;
                NSUInteger r = i;
                NSUInteger g = i+1;
                NSUInteger b = i+2;
                NSUInteger a = i+3;
                
                UInt8 red     = pixelBuf[r];
                UInt8 green   = pixelBuf[g];
                UInt8 blue    = pixelBuf[b];
                UInt8 alpha   = pixelBuf[a];
                NSUInteger color = colorblock(red, green, blue, alpha);
                
                pixelBuf[r] = color >> 24 & 0xff;
                pixelBuf[g] = color >> 16 & 0xff;
                pixelBuf[b] = color >> 8 & 0xff;
                pixelBuf[a] = color & 0xff;

            }
        }
    }];
}

- (UIImage*)imageReversaY {
    return [self operationImageWithBlock:^(UInt8 *pixelBuf, size_t width, size_t height, size_t bits, size_t bitsPerRow) {
        size_t unit = bitsPerRow/width;
        typeof (void (^)(size_t, size_t)) conversion = ^(size_t x, size_t y){
            UInt8 colorUint;
            size_t index_x = x*unit;
            size_t index_y = y*unit;
            for (size_t i = 0; i < unit; i ++) {
                colorUint = pixelBuf[index_x+i];
                pixelBuf[index_x+i] = pixelBuf[index_y+i];
                pixelBuf[index_y+i] = colorUint;
            }
            
        };
        for (size_t cell = 0; cell < width; cell ++) {
            for (size_t row = 0; row < height/2; row ++) {
                conversion(row*width + cell,(height - row)*width + cell);
            }
        }
    }];
}

- (UIImage*)imageReversaX {
    UIImage *image = self;
    if(kiOS9Later){
        image = [self imageFlippedForRightToLeftLayoutDirection];
        if(image.flipsForRightToLeftLayoutDirection){
            return image;
        }else if(kiOS10Later){
            image = [self imageWithHorizontallyFlippedOrientation];
            return image;
        }
        
    }
//    return image;
    return [self operationImageWithBlock:^(UInt8 *pixelBuf, size_t width, size_t height, size_t bits, size_t bitsPerRow) {
        size_t unit = bitsPerRow/width;
        typeof (void (^)(size_t, size_t)) conversion = ^(size_t x, size_t y){
            UInt8 colorUint;
            size_t index_x = x*unit;
            size_t index_y = y*unit;
            for (size_t i = 0; i < unit; i ++) {
                colorUint = pixelBuf[index_x+i];
                pixelBuf[index_x+i] = pixelBuf[index_y+i];
                pixelBuf[index_y+i] = colorUint;
            }
            
        };
        for (size_t row = 0; row < height; row ++) {
            for (size_t cell = 0; cell < width/2; cell ++) {
                conversion(row*width + cell,(row+1)*width - cell);
            }
        }
    }];
}

- (UIImage *)mc_imageByFilledColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, 0, self.scale);
    [color set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = CGRectZero;
    bounds.size = self.size;
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, bounds, self.CGImage);
    CGContextFillRect(context, bounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)mc_resizable {
    CGSize size = self.size;
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(size.height/2.0, size.width/2.0, size.height/2.0, size.width/2.0)
                                resizingMode:UIImageResizingModeTile];
}

- (UIImage *)mc_stretchable {
    return [self resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
}

//================= Class Mehtods =====================
+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithRadius:(CGFloat)radius color:(UIColor *)color
{
    return [self imageWithSize:CGSizeZero radius:radius color:color];
}

+ (UIImage *)imageWithRadius:(CGFloat)radius color:(UIColor *)color resizableStretch:(BOOL)resizableStretch
{
    UIImage *image = [self imageWithSize:CGSizeZero radius:radius color:color];
    if (resizableStretch) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    }
    return image;
}

+ (UIImage *)imageWithAnnulusRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
     NSCParameterAssert(radius >= borderWidth);
    return [self imageWithSize:CGSizeZero radius:radius color:nil borderWidth:borderWidth borderColor:borderColor];
}


+ (UIImage *)imageWithSize:(CGSize)size radius:(CGFloat)radius color:(UIColor *)color
{
    return [self imageWithSize:size radius:radius color:color borderWidth:0 borderColor:nil];
}

+ (UIImage *)imageWithSize:(CGSize)size radius:(CGFloat)radius color:(UIColor *)color
               borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    NSCParameterAssert(size.width > 0 || size.height > 0 || radius > 0);
    NSCParameterAssert(color || borderColor);
    
    if ((size.width / 2.0 < radius || size.height / 2.0 < radius) && radius > 0) {
        size.width = MAX(radius * 2, size.width);
        size.height = MAX(radius * 2, size.height);
    }

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *path = nil;
    
    if (borderWidth > 0 && size.width > borderWidth && size.height > borderWidth) {
        UIEdgeInsets insets = UIEdgeInsetsMake(borderWidth / 2.f, borderWidth / 2.f,
                                               borderWidth / 2.f, borderWidth / 2.f);
        rect = UIEdgeInsetsInsetRect(rect, insets);
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    }
    
    [path setLineWidth:borderWidth];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (color) {
        [color set];
        [path fill];
    }
    
    if (borderColor) {
        [borderColor setStroke];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (radius > 0 || borderWidth > 0) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(size.height/2.0, size.width/2.0, size.height/2.0, size.width/2.0)
                                      resizingMode:UIImageResizingModeTile];
    }
    
    return image;
}


+ (UIImage *)backgroundImageWithColor:(UIColor *)color radius:(CGFloat)radius {
    return [UIImage backgroundImageWithColor:color radius:radius borderWidth:0 borderColor:color];
}

+ (UIImage *)backgroundImageWithColor:(UIColor *)color
                               radius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor {
    UIImage *image = [UIImage imageWithSize:CGSizeMake(10.f, 10.f)
                                     radius:radius
                                      color:color
                                borderWidth:borderWidth
                                borderColor:borderColor];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f) resizingMode:UIImageResizingModeTile];
    return image;
}

+ (UIImage *)lineImageWithColor:(UIColor *)color lineWidth:(CGFloat)lineWidth size:(CGSize)size
{
    NSCParameterAssert(size.width >= lineWidth && size.height >= lineWidth && lineWidth > 0);
    NSCParameterAssert(color);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:lineWidth];
    
    if (size.width >= size.height) {
        [path moveToPoint:CGPointMake(0, lineWidth/2.0)];
        [path addLineToPoint:CGPointMake(size.width, lineWidth/2.0)];
    } else {
        [path moveToPoint:CGPointMake(lineWidth/2.0, 0)];
        [path addLineToPoint:CGPointMake(lineWidth/2.0, size.height)];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [color set];
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithPath:(UIBezierPath *)path size:(CGSize)size fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    NSCParameterAssert(fillColor || strokeColor);
    if (size.width == 0 && size.height == 0) size = path.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (fillColor) {
        [fillColor set];
        [path fill];
    }
    
    if (strokeColor) {
        [strokeColor setStroke];
        [path stroke];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)launchImageWithOrientation:(UIDeviceOrientation)orientation {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    NSString *viewOrientation = @"Portrait";
    if (UIDeviceOrientationIsLandscape(orientation)) {
        viewSize = CGSizeMake(viewSize.height, viewSize.width);
        viewOrientation = @"Landscape";
    }
    
    NSString *launchImage = nil;
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize)
            && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    if (launchImage) {
        return [UIImage imageNamed:launchImage];
    } else {
        return nil;
    }
}

//- ()

@end


@implementation UIImage (Resized)

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // In iOS 5 the image is already correctly rotated. See Eran Sandler's
    // addition here: http://eran.sandler.co.il/2011/11/07/uiimage-in-ios-5-orientation-and-resize/
    
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 5.0) {
        drawTransposed = YES;
    }
    else {
        switch(self.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                drawTransposed = YES;
                break;
            default:
                drawTransposed = NO;
        }
        
        transform = [self mc_transformForOrientation:newSize];
    }
    transform = [self mc_transformForOrientation:newSize];
    return [self mc_resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch(contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %@", @(contentMode)];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}


#pragma mark - fix orientation
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

static inline CGFloat DegreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

- (UIImage *)rotatedByDegrees:(CGFloat)degrees withScale:(CGFloat)scale {
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    //UIGraphicsBeginImageContext(rotatedSize);
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)rotatedByDegrees:(CGFloat)degrees
{
    return [self rotatedByDegrees:degrees withScale:0];
}

#pragma mark -
#pragma mark Private helper methods

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)mc_resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        transposedRect = newRect;
    }
    CGImageRef imageRef = self.CGImage;
    
    // Fix for a colorspace / transparency issue that affects some types of
    // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8,
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                kCGImageAlphaNoneSkipLast);
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)mc_transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch(self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch(self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

@end
