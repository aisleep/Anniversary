//
//  AIQTableView.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQTableView.h"

@implementation AIQTableView
@dynamic dataSource;

- (void)setDataSource:(id<AIQTableViewDataSource>)dataSource {
    [super setDataSource:dataSource];
    if ([dataSource respondsToSelector:@selector(classesForTableViewRegisterCell)]) {
        for (Class clazz in [dataSource classesForTableViewRegisterCell]) {
            if ([clazz respondsToSelector:@selector(reuseIdentifier)]) {
                [self registerClass:clazz
             forCellReuseIdentifier:[clazz performSelector:@selector(reuseIdentifier)]];
            }
        }
    }
}

@end
