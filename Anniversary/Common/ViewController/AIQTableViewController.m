//
//  AIQTableViewController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQTableViewController.h"

@interface AIQTableViewController ()

@end

@implementation AIQTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super init];
    if (self) {
        _tableViewStyle = style;
        _clearsSelectionOnViewWillAppear = YES;
        _tableNode = [[AIQTableNode alloc] initWithStyle:_tableViewStyle];
        _tableNode.dataSource = self;
        _tableNode.delegate = self;
        [self.node addSubnode:_tableNode];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableNode.frame = self.node.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_clearsSelectionOnViewWillAppear && _tableNode.indexPathForSelectedRow) {
        [_tableNode deselectRowAtIndexPath:_tableNode.indexPathForSelectedRow animated:animated];
    }
}

@end
