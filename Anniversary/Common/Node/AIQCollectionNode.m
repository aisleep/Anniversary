//
//  AIQCollectionNode.m
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionNode.h"

@implementation AIQCollectionNode

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout layoutFacilitator:(nullable id<ASCollectionViewLayoutFacilitatorProtocol>)layoutFacilitator {
    self = [super initWithFrame:frame collectionViewLayout:layout layoutFacilitator:layoutFacilitator];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
