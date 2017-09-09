//
//  AIQCollectionViewController.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQViewController.h"
#import "AIQCollectionNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIQCollectionViewController : AIQViewController <ASCollectionDataSource, ASCollectionDelegate>

@property (nonatomic, strong, readonly) AIQCollectionNode *collectionNode;

@property (nonatomic, strong, readonly) UICollectionViewLayout *collectionViewLayout;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

@end

NS_ASSUME_NONNULL_END
