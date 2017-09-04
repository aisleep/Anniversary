//
//  AIQAlbumsService.m
//  Anniversary
//
//  Created by 小希 on 2017/9/1.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumsService.h"
#import <Photos/Photos.h>

@implementation AIQAlbumsService

+ (void)queryPhotoLibraryAuthorizationStatus:(AIQBoolResultBlock)result {
    PHAuthorizationStatus phAuthStatus = [PHPhotoLibrary authorizationStatus];
    if (phAuthStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_sync_on_main_queue(^{
                    result(YES);
                });
            } else {
                dispatch_sync_on_main_queue(^{
                    result(NO);
                });
            }
        }];
    }
    else if (phAuthStatus == PHAuthorizationStatusAuthorized) {
        dispatch_sync_on_main_queue(^{
            result(YES);
        });
    }
    else {
        dispatch_sync_on_main_queue(^{
            result(NO);
        });
    }
}

+ (void)fetchAllPhotoAlbums:(void (^)(NSArray<AIQAlbum *> * _Nonnull, NSArray<AIQAlbum *> * _Nonnull))result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHFetchOptions *albumOptions = [[PHFetchOptions alloc] init];
        albumOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES]];
        //经由相机得来的相册
        PHFetchResult<PHAssetCollection *> *smartAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:albumOptions];
        //从 iTunes 同步来的相册，以及用户在 Photos 中自己建立的相册
        PHFetchResult<PHAssetCollection *> *customAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:albumOptions];
        
        NSMutableArray *systemAlbums = [NSMutableArray array];
        NSMutableArray *customAlbums = [NSMutableArray array];
        DDLogInfo(@"[PHAssetCollectionTypeSmartAlbum] ==================");
        [smartAlbumResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AIQAlbum *album = [self transformPHAssetCollectionIntoAIQAlbums:obj];
            if (album) {
                [systemAlbums addObject:album];
            }
            DDLogDebug(@"[albums name:%@ subtype:%ld count:%ld]", obj.localizedTitle, obj.assetCollectionSubtype, obj.estimatedAssetCount);
        }];
        
        DDLogDebug(@"[PHAssetCollectionTypeAlbum] ==================");
        [customAlbumResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AIQAlbum *album = [self transformPHAssetCollectionIntoAIQAlbums:obj];
            if (album) {
                [customAlbums addObject:album];
            }
            DDLogDebug(@"[albums name:%@ subtype:%ld count:%ld]", obj.localizedTitle, obj.assetCollectionSubtype, obj.estimatedAssetCount);
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                result(systemAlbums.copy, customAlbums.copy);
            }
        });
    });
}

+ (AIQAlbum *)transformPHAssetCollectionIntoAIQAlbums:(PHAssetCollection *)assetCollection {
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if (fetchResult.count == 0) {
        return nil;
    }
    AIQAlbum *album = [[AIQAlbum alloc] init];
    album.localIdentifier = assetCollection.localIdentifier;
    album.title = assetCollection.localizedTitle;
    album.photoCount = fetchResult.count;
    album.assetCollection = assetCollection;
    return album;
}

+ (void)fetchAllPhotoAssetsInAlbum:(PHAssetCollection *)album completeHandler:(void (^)(NSArray<PHAsset *> * _Nonnull))result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:album options:nil];
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:fetchResult.count];
        [fetchResult enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [photos addObject:obj];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                result(photos.copy);
            }
        });
    });
}

#pragma mark - Save To Album 
+ (void)saveImagesToLocalAlbum:(NSArray *)images completeBlock:(void (^)(BOOL, PHFetchResult<PHAsset *> *))complete {
    if (!images.count) {
        return;
    }
    [self PH_saveImageToCustomAlbumWithImages:images compelteBlock:complete];
}

+ (void)saveVideoToLocalAlbum:(NSString *)filePath
         existLocalIdentifier:(NSString *)localIdentifier
                completeBlock:(nullable void (^)(BOOL, PHAsset * _Nonnull))complete {
    if (localIdentifier) {
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
        if (result && result.count > 0) {
            PHAsset *asset = [result objectAtIndex:0];
            if (complete) {
                complete(YES, asset);
            }
            return;
        }
    }
    [self PH_saveVideoToCustomAlbumWithVideoPath:filePath compelteBlock:complete];
}

#pragma mark - iOS8之后的接口
+ (void)PH_saveVideoToCustomAlbumWithVideoPath:(NSString *)videoPath compelteBlock:(void(^)(BOOL success, PHAsset *fetchResult))compelte {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // 获取保存到相机胶卷中的视频
            PHFetchResult *fetchResult = [self createdAssetsWithVideoPath:videoPath];
            if (!fetchResult) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    compelte? compelte(NO, nil) : 0;
                });
                return;
            }
            [self PH_saveFetchResultToMicoAlbum:fetchResult compelteBlock:^(BOOL success, PHFetchResult<PHAsset *> *fetchResult) {
                PHAsset *asset = nil;
                if (success) {
                    asset = [fetchResult objectAtIndex:0];
                }
                if (compelte) {
                    compelte(success, asset);
                }
            }];
            return;
        }
        DDLogInfo(@"[未获取相册权限]");
        dispatch_async(dispatch_get_main_queue(), ^{
            compelte? compelte(NO, nil) : 0;
        });
    }];
}

+ (void)PH_saveImageToCustomAlbumWithImages:(NSArray*)images compelteBlock:(void(^)(BOOL success, PHFetchResult<PHAsset *> *fetchResult))compelte {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            // 获取保存到相机胶卷中的图片
            PHFetchResult *fetchResult = [self createdAssetsWithImages:images];
            if (!fetchResult) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    compelte? compelte(NO, nil) : 0;
                });
                return;
            }
            [self PH_saveFetchResultToMicoAlbum:fetchResult compelteBlock:compelte];
            return;
        }
        DDLogInfo(@"[未获取相册权限]");
        dispatch_async(dispatch_get_main_queue(), ^{
            compelte? compelte(NO, nil) : 0;
        });
    }];
}

+ (void)PH_saveFetchResultToMicoAlbum:(PHFetchResult *)fetchResult compelteBlock:(void(^)(BOOL success, PHFetchResult<PHAsset *> *fetchResult))compelte  {
    // 获取Mico相册
    PHAssetCollection *createdCollection = [self createMicoAssetCollection];
    if (!createdCollection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            compelte? compelte(NO, nil) : 0;
        });
        return;
    }
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request addAssets:fetchResult];
    } error:&error];
    if (error) {
        DDLogError(@"媒体存储进Mico相册失败 error:%@", error);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL success = !error;
        PHFetchResult *result = success ? fetchResult : nil;
        compelte? compelte(success, result) : 0;
    });
}

#pragma mark - 获取保存到【相机胶卷】的图片
+ (PHFetchResult<PHAsset *> *)createdAssetsWithImages:(NSArray*)images {
    // 将图片保存到相机胶卷
    NSMutableArray *assetIDs = [NSMutableArray arrayWithCapacity:images.count];
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
            [assetIDs addObject:assetID];
        }];
    } error:&error];
    if (error) {
        DDLogError(@"图片存储进系统相册失败 error:%@", error);
        return nil;
    }
    return [PHAsset fetchAssetsWithLocalIdentifiers:assetIDs options:nil];
}

+ (PHFetchResult<PHAsset *> *)createdAssetsWithVideoPath:(NSString *)videoPath {
    __block NSString *assetID = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:videoPath]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) {
        DDLogError(@"视频存储进系统相册失败 error:%@", error);
        return nil;
    }
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

#pragma mark - 获取Mico相册
+ (PHAssetCollection *)createMicoAssetCollection {
    NSString *title = @"AIQ";
    NSError *error = nil;
    
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeAlbum)
                                                                                          subtype:(PHAssetCollectionSubtypeAlbumRegular)
                                                                                          options:nil];
    
    for (PHAssetCollection *collection in result) {
        if ([collection.localizedTitle isEqualToString:title]) { // 说明 app 中存在该相册
            return collection;
        }
    }
    
    /** 来到这里说明相册不存在 需要创建相册 **/
    __block NSString *createdCustomAssetCollectionIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createdCustomAssetCollectionIdentifier = collectionChangeRequest.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        DDLogError(@"创建相册失败 error:%@", error);
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCustomAssetCollectionIdentifier] options:nil].firstObject;
}

@end
