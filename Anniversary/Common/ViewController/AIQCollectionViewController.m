//
//  AIQCollectionViewController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionViewController.h"

@interface AIQCollectionViewController ()

@end

@implementation AIQCollectionViewController
@dynamic collectionView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.installsStandardGestureForInteractiveMovement = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.collectionView = [[AIQCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - AIQCollectionViewDataSource
- (NSArray<Class> *)classesForTableViewRegisterCell {
    return @[[AIQCollectionViewCell reuseIdentifier]];
}

@end
