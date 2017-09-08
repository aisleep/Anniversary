//
//  UIFont+Extension.m
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "UIFont+Extension.h"

@implementation UIFont (Extension)

+ (instancetype)aiqUltraLightFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightUltraLight];
}

+ (instancetype)aiqThinFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightThin];
}

+ (instancetype)aiqLightFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (instancetype)aiqRegularFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightRegular];
}

+ (instancetype)aiqMediumFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightMedium];
}

+ (instancetype)aiqSemiboldFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightSemibold];
}

+ (instancetype)aiqBoldFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightBold];
}

+ (instancetype)aiqHeavyFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightHeavy];
}

+ (instancetype)aiqBlackFontOfSize:(CGFloat)fontSize {
    return [self systemFontOfSize:fontSize weight:UIFontWeightBlack];
}

+ (instancetype)aiqPingFangFontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:size];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

+ (instancetype)aiqPingFangLightFontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Light" size:size];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

+ (instancetype)aiqPingFangMediumFontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:size];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

@end
