//
//  AIQAlbumViewModel.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIQAlbum.h"
#import "AIQPhoto.h"

@interface AIQAlbumViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray<AIQPhoto *> *thumbnailsForSelectedAlbum;
@property (nonatomic, strong, readonly) NSArray<AIQPhoto *> *originalImageForSelectedAlbum;

@property (nonatomic, strong) AIQAlbum *selectedAlbum;

@property (nonatomic, strong, readonly) NSArray<AIQAlbum *> * systemAlbums;
@property (nonatomic, strong, readonly) NSArray<AIQAlbum *> * customAlbums;

- (instancetype)initWithThumbnailSize:(CGSize)thumbnailSize;

- (void)initializeAlbum:(void(^)(BOOL success))completeHandler;

- (void)fetchPhotosAtAlbum:(AIQAlbum *)album completeHandler:(void(^)())completeHandler;

- (void)unloadThumbnails;

@end
