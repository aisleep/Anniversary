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

@property (nonatomic, strong) NSMutableSet *selectPhotoLocalIdentifierSet;
@property (nonatomic, strong) NSMutableArray<AIQPhoto *> *selectPhotosArray;

@end

@implementation AIQAlbumViewModel

- (instancetype)initWithThumbnailSize:(CGSize)thumbnailSize {
    self = [super init];
    if (self) {
        _thumbnailsSize = thumbnailSize;
        _selectPhotoLocalIdentifierSet = [NSMutableSet set];
        _selectPhotosArray = [NSMutableArray array];
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

- (void)selectPhotoAtIndex:(NSUInteger)index {
    AIQPhoto *photo = [self photoInOriginalImageAtIndex:index isSelected:NULL];
    if (!photo) {
        return;
    }
    [_selectPhotosArray addObject:photo];
    [_selectPhotoLocalIdentifierSet addObject:photo.localIdentifier];
}

- (BOOL)isPhotoSelectedAtIndex:(NSUInteger)index {
    BOOL isSelected = NO;
    [self photoInOriginalImageAtIndex:index isSelected:&isSelected];
    return isSelected;
}

- (void)removeSelectedPhotoAtIndex:(NSUInteger)index {
    BOOL isSelected = NO;
    AIQPhoto *photo = [self photoInOriginalImageAtIndex:index isSelected:&isSelected];
    if (!isSelected) {
        return;
    }
    
    __block NSInteger selectedIndex = NSNotFound;
    [_selectPhotosArray enumerateObjectsUsingBlock:^(AIQPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localIdentifier isEqualToString:photo.localIdentifier]) {
            selectedIndex = idx;
            *stop = YES;
        }
    }];
    if (selectedIndex != NSNotFound) {
        [_selectPhotosArray removeObjectAtIndex:selectedIndex];
    }
}

- (AIQPhoto *)photoInOriginalImageAtIndex:(NSUInteger)index isSelected:(BOOL *)isSelected {
    if (index >= _numberOfPhoto) {
        if (isSelected) {
            *isSelected = NO;
        }
        return nil;
    }
    AIQPhoto *photo = [_originalImageForSelectedAlbum objectAtIndex:index];
    if (isSelected) {
        *isSelected = [_selectPhotoLocalIdentifierSet containsObject:photo.localIdentifier];
    }
    return photo;
}

#pragma mark - Clear Cache

- (void)unloadPhotoImages {
    [_thumbnailsForSelectedAlbum enumerateObjectsUsingBlock:^(AIQPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj unloadUnderlyingImage];
    }];
    [_originalImageForSelectedAlbum enumerateObjectsUsingBlock:^(AIQPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj unloadUnderlyingImage];
    }];
}

@end
