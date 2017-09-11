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

static CGFloat OriginalImageMaximumSize = 5000;

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
        NSMutableArray *thumbnailPhotoModels = [NSMutableArray arrayWithCapacity:photos.count];
        NSMutableArray *originalPhotoModels = [NSMutableArray arrayWithCapacity:photos.count];
        CGSize originalMaxSize = CGSizeMake(OriginalImageMaximumSize, OriginalImageMaximumSize);
        [photos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AIQPhoto *thumbnailphoto = [AIQPhoto photoWithAsset:obj targetSize:_thumbnailsSize];
            thumbnailphoto.isThumbnail = YES;
            [thumbnailPhotoModels addObject:thumbnailphoto];
            AIQPhoto *originalphoto = [AIQPhoto photoWithAsset:obj targetSize:originalMaxSize];
            [originalPhotoModels addObject:originalphoto];
        }];
        _numberOfPhoto = photos.count;
        _thumbnailsForSelectedAlbum = thumbnailPhotoModels.copy;
        _originalImageForSelectedAlbum = originalPhotoModels.copy;
        if (completeHandler) {
            completeHandler();
        }
    }];
}

- (void)unloadPhotoImages {
    [_thumbnailsForSelectedAlbum enumerateObjectsUsingBlock:^(AIQPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj unloadUnderlyingImage];
    }];
    [_originalImageForSelectedAlbum enumerateObjectsUsingBlock:^(AIQPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj unloadUnderlyingImage];
    }];
}

#pragma mark - AIQAlbumBrowserDataSource
- (NSUInteger)numberOfPhotosInPhotoBrowser:(AIQAlbumBrowser *)photoBrowser {
    return _numberOfPhoto;
}

- (id<MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _originalImageForSelectedAlbum.count) {
        return [_originalImageForSelectedAlbum objectAtIndex:index];
    }
    return nil;
}

- (id<MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbnailsForSelectedAlbum.count) {
        return [_thumbnailsForSelectedAlbum objectAtIndex:index];
    }
    return nil;
}

@end
