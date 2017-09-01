//
//  AIQPhoto.h
//  Anniversary
//
//  Created by 小希 on 2017/9/1.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

@class PHAsset;
@interface AIQPhoto : NSObject <MWPhoto>

@property (nonatomic, strong) UIImage *underlyingImage;

@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

@property (nonatomic, copy) NSString *localIdentifier;  //本地标识

+ (instancetype)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;


@end
