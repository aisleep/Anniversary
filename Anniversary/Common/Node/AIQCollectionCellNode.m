//
//  AIQCollectionCellNode.m
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionCellNode.h"

@implementation AIQCollectionCellNode

- (ASImageNode *)imageNode {
    if (!_imageNode) {
        _imageNode = [[ASImageNode alloc] init];
        [self addSubnode:_imageNode];
    }
    return _imageNode;
}

@end
