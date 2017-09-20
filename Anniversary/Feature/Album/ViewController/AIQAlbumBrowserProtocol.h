//
//  AIQAlbumBrowserProtocol.h
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"

@class AIQAlbumBrowser;

@protocol AIQAlbumBrowserDataSource <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(AIQAlbumBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional
- (id <MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;

@end

@protocol AIQAlbumBrowserDelegate  <NSObject>

@optional
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser updateNavigationTitleAtIndex:(NSUInteger)index;
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(AIQAlbumBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(AIQAlbumBrowser *)photoBrowser;

@end
