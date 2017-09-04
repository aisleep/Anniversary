//
//  AIQCollectionViewCell.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionViewCell.h"

@implementation AIQCollectionViewCell {
    UIImageView *_imageView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
