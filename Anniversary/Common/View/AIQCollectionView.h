//
//  AIQCollectionView.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIQCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AIQCollectionViewDataSource <UICollectionViewDataSource>

@required
- (NSArray<Class> *)classesForTableViewRegisterCell;

@end

@interface AIQCollectionView : UICollectionView

@property (nonatomic, weak, nullable) id <AIQCollectionViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
