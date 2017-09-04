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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _tableViewStyle = style;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[AIQTableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_clearsSelectionOnViewWillAppear && _tableView.indexPathForSelectedRow) {
        [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
    }
}

#pragma mark - AIQTableViewDataSource
- (NSArray<Class> *)classesForTableViewRegisterCell {
    return @[[AIQTableViewCell class]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AIQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[AIQTableViewCell reuseIdentifier] forIndexPath:indexPath];
    return cell;
}

@end
