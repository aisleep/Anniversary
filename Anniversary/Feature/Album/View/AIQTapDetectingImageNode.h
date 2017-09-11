//
//  AIQTapDetectingImageNode.h
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <AsyncDisplayKit/ASImageNode.h>


@protocol AIQTapDetectingImageNodeDelegate;

@interface AIQTapDetectingImageNode : ASImageNode

@property (nonatomic, weak) id <AIQTapDetectingImageNodeDelegate> tapDelegate;

@end

@protocol AIQTapDetectingImageNodeDelegate <NSObject>

@optional

- (void)imageNode:(ASImageNode *)imageNode singleTapDetected:(UITouch *)touch;
- (void)imageNode:(ASImageNode *)imageNode doubleTapDetected:(UITouch *)touch;
- (void)imageNode:(ASImageNode *)imageNode tripleTapDetected:(UITouch *)touch;

@end
