//
//  AIQAlbumsService.h
//  Anniversary
//
//  Created by 小希 on 2017/9/1.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PHCollection.h>
#import <Photos/PHAsset.h>
#import "AIQAlbum.h"

NS_ASSUME_NONNULL_BEGIN

@interface AIQAlbumsService : NSObject

#pragma mark - AuthorizationStatus
+ (void)queryPhotoLibraryAuthorizationStatus:(AIQBoolResultBlock)result;
//+ (void)queryCameraAuthorizationStatus:(AIQBoolResultBlock)result;

#pragma mark - PhotoLibrary
+ (void)fetchAllPhotoAlbums:(void(^)(NSArray<AIQAlbum *> *systemAlbums, NSArray<AIQAlbum *> *customAlbums))result;

+ (void)fetchAllPhotoAssetsInAlbum:(PHAssetCollection *)album completeHandler:(void(^)(NSArray<PHAsset *> *photos))result;

#pragma mark - SaveToAlbum
+ (void)saveImagesToLocalAlbum:(NSArray *)images completeBlock:(nullable void (^)(BOOL success, PHFetchResult<PHAsset *> *fetchResult))complete;

/**
 保存视频至本地相册
 
 @param filePath 视频的本地路径
 @param localIdentifier 已存在相册中的本地标识, 用于判断视频是否已存在相册中
 @param complete 完成回调, fetchResult 中的 PHAsset 附带存储后的相关信息, 包括localIdentifier
 */
+ (void)saveVideoToLocalAlbum:(NSString *)filePath
         existLocalIdentifier:(nullable NSString *)localIdentifier
                completeBlock:(nullable void (^)(BOOL success, PHAsset *asset))complete;

@end

NS_ASSUME_NONNULL_END
