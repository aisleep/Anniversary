//
//  AIQTapDetectingImageNode.m
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQTapDetectingImageNode.h"

@implementation AIQTapDetectingImageNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self.view nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(imageNode:singleTapDetected:)])
        [_tapDelegate imageNode:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(imageNode:doubleTapDetected:)])
        [_tapDelegate imageNode:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(imageNode:tripleTapDetected:)])
        [_tapDelegate imageNode:self tripleTapDetected:touch];
}

@end
