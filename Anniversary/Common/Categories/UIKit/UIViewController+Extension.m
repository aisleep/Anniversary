//
//  UIViewController+Extension.m
//  Anniversary
//
//  Created by 小希 on 2017/9/8.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)returnToPreviousPage {
    if (self.navigationController && self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIBarButtonItem *)aiq_BackBarItem {
   return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(returnToPreviousPage)];
}

@end
