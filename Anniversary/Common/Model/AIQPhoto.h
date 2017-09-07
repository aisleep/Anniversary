//
//  AIQPhoto.h
//  Anniversary
//
//  Created by 小希 on 2017/9/1.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

extern CGSize const PHImageManagerMaximumSize;

@class PHAsset;
@interface AIQPhoto : NSObject <MWPhoto>

@property (nonatomic, strong) UIImage *underlyingImage;

@property (nonatomic, strong) UIImage *originalImage; //原图
@property (nonatomic, strong) UIImage *thumbnail;   //缩略图

@property (nonatomic, strong) NSString *caption;

@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;
@property (nonatomic) BOOL isThumbnail; //是否是只需获取缩略图
@property (nonatomic) BOOL isInCloud;

@property (nonatomic, copy) NSString *localIdentifier;  //本地标识

+ (instancetype)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;


@end
