//
//  AIQTableViewController.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQViewController.h"
#import "AIQTableNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIQTableViewController : AIQViewController <ASTableDataSource, ASTableDelegate>

@property (nonatomic, strong, readonly) AIQTableNode *tableNode;

@property (nonatomic, assign, readonly) UITableViewStyle tableViewStyle;

@property (nonatomic) BOOL clearsSelectionOnViewWillAppear; // defaults to YES. If YES, any selection is cleared in viewWillAppear:

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end

NS_ASSUME_NONNULL_END
