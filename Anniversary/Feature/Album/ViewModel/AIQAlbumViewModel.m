//
//  AIQAlbumViewModel.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumViewModel.h"
#import "AIQAlbumsService.h"
#import "AIQPhoto.h"

@interface AIQAlbumViewModel ()

@property (nonatomic, assign) CGSize thumbnailsSize;

@end

@implementation AIQAlbumViewModel

- (instancetype)initWithThumbnailSize:(CGSize)thumbnailSize {
    self = [super init];
    if (self) {
        _thumbnailsSize = thumbnailSize;
    }
    return self;;
}

- (void)initializeAlbum:(void (^)(BOOL))completeHandler  {
    [AIQAlbumsService queryPhotoLibraryAuthorizationStatus:^(BOOL result) {
        if (!result) {
            if (completeHandler) {
                completeHandler(NO);
            }
            return;
        }
        [AIQAlbumsService fetchAllPhotoAlbums:^(NSArray<AIQAlbum *> * _Nonnull systemAlbums, NSArray<AIQAlbum *> * _Nonnull customAlbums) {
            _systemAlbums = systemAlbums;
            _customAlbums = customAlbums;
            _selectedAlbum = systemAlbums.firstObject;
            if (completeHandler) {
                completeHandler(YES);
            }
        }];
    }];
}

- (void)fetchPhotosAtAlbum:(AIQAlbum *)album completeHandler:(void (^)())completeHandler {
    [AIQAlbumsService fetchAllPhotoAssetsInAlbum:album.assetCollection completeHandler:^(NSArray<PHAsset *> * _Nonnull photos) {
        NSMutableArray *photoModels = [NSMutableArray arrayWithCapacity:photos.count];
        [photos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AIQPhoto *photo = [AIQPhoto photoWithAsset:obj targetSize:_thumbnailsSize];
            photo.isThumbnail = YES;
            [photoModels addObject:photo];
        }];
        _thumbnailsForSelectedAlbum = photoModels.copy;
        if (completeHandler) {
            completeHandler();
        }
    }];
}

@end
