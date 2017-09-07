//
//  AIQAppManager.m
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAppManager.h"
#import "AIQNetWorkSatusManager.h"

@implementation AIQAppManager

+ (void)setup {
    [[AIQNetWorkSatusManager sharedInstance] startMonitoring]; //检测网络变化
}

@end
