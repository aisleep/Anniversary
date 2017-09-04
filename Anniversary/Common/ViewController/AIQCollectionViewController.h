//
//  AIQCollectionViewController.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQBasicViewController.h"
#import "AIQCollectionView.h"
#import "AIQCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIQCollectionViewController : UICollectionViewController <AIQCollectionViewDataSource>

@property (nonatomic, strong) __kindof AIQCollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
