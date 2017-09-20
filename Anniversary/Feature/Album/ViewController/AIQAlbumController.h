//
//  AIQAlbumController.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQCollectionViewController.h"

typedef NS_ENUM(NSInteger, AIQAlbumSelectMode) {
    AIQAlbumSelectModeSingle,
    AIQAlbumSelectModeMultiple,
};

@class AIQPhoto;
@interface AIQAlbumController : AIQCollectionViewController

@property (nonatomic, assign) AIQAlbumSelectMode selectMode;

@property (nonatomic, strong) void(^completeSelectedHanlder)(NSArray<AIQPhoto *> *selectedPhotos);

@end
