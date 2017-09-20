//
//  AIQAlbumViewModel.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIQAlbumBrowserProtocol.h"
#import "AIQAlbum.h"
#import "AIQPhoto.h"

@interface AIQAlbumViewModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger numberOfPhoto; //当前照片数量

@property (nonatomic, strong, readonly) NSArray<AIQPhoto *> *thumbnailsForSelectedAlbum;    //照片缩略图
@property (nonatomic, strong, readonly) NSArray<AIQPhoto *> *originalImageForSelectedAlbum; //照片原图
@property (nonatomic, strong, readonly) NSArray<AIQAlbum *> *systemAlbums;                  //系统相册集
@property (nonatomic, strong, readonly) NSArray<AIQAlbum *> *customAlbums;                  //自定义相册集
@property (nonatomic, strong, readonly) NSArray<AIQPhoto *> *selectedPhotos;                //选中的照片

@property (nonatomic, strong) AIQAlbum *selectedAlbum;  //当前选中的相册

- (instancetype)initWithThumbnailSize:(CGSize)thumbnailSize;

- (void)initializeAlbum:(void(^)(BOOL success))completeHandler;
- (void)fetchPhotosAtAlbum:(AIQAlbum *)album completeHandler:(void(^)())completeHandler;

- (void)selectPhotoAtIndex:(NSUInteger)index;
- (void)removeSelectedPhotoAtIndex:(NSUInteger)index;
- (BOOL)isPhotoSelectedAtIndex:(NSUInteger)index;

#pragma mark Clear Cache
- (void)unloadPhotoImages;

@end
