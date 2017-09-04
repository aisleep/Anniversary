//
//  AIQTableViewController.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQBasicViewController.h"
#import "AIQTableView.h"
#import "AIQTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIQTableViewController : AIQBasicViewController <AIQTableViewDataSource, UITableViewDelegate>
{
    @protected
    AIQTableView *_tableView;
}

@property (nonatomic, strong, readonly) AIQTableView *tableView;

@property (nonatomic, assign, readonly) UITableViewStyle tableViewStyle;

@property (nonatomic) BOOL clearsSelectionOnViewWillAppear; // defaults to YES. If YES, any selection is cleared in viewWillAppear:

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end

NS_ASSUME_NONNULL_END
