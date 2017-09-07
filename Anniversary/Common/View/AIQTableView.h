//
//  AIQTableView.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import "AIQTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AIQTableViewDataSource <UITableViewDataSource>

@required
- (NSArray<Class> *)classesForTableViewRegisterCell;
- (NSArray<Class> *)classesForTableViewRegisterHeaderFooterView;

@end

@interface AIQTableView : UITableView

@property (nonatomic, weak, nullable) id <AIQTableViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
