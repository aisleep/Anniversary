//
//  AIQCollectionView.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionView.h"

@implementation AIQCollectionView
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setDataSource:(id<AIQCollectionViewDataSource>)dataSource {
    [super setDataSource:dataSource];
    if ([self.dataSource respondsToSelector:@selector(classesForCollectionViewRegisterCell)]) {
        for (Class clazz in [self.dataSource classesForCollectionViewRegisterCell]) {
            if ([clazz respondsToSelector:@selector(reuseIdentifier)]) {
                [self registerClass:clazz
         forCellWithReuseIdentifier:[clazz performSelector:@selector(reuseIdentifier)]];
            }
        }
    }
}

@end
