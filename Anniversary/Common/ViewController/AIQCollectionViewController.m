//
//  AIQCollectionViewController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionViewController.h"
#import "AIQCollectionNode.h"

@interface AIQCollectionViewController ()

@end

@implementation AIQCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        _collectionViewLayout = layout;
        _collectionNode = [[AIQCollectionNode alloc] initWithCollectionViewLayout:layout];
        _collectionNode.dataSource = self;
        _collectionNode.delegate = self;
        [self.node addSubnode:self.collectionNode];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _collectionNode.frame = self.node.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
