//
//  AIQAlbumBrowser.h
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQViewController.h"
#import "AIQAlbumBrowserProtocol.h"
#import "MWCaptionView.h"
#import "AIQPhoto.h"

@interface AIQAlbumBrowser : AIQViewController

@property (nonatomic, weak) id <AIQAlbumBrowserDataSource> dataSource;
@property (nonatomic, weak) id <AIQAlbumBrowserDelegate> delegate;

@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL enableSwipeToDismiss;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
