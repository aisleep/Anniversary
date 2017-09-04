//
//  AIQAlbumSelectView.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQTableView.h"

@class AIQAlbum;
@interface AIQAlbumSelectView : AIQTableView

@property (nonatomic, strong) void(^selectAlbumHanler)(AIQAlbum *selectedAlbum);

- (instancetype)initWithFrame:(CGRect)frame
                     systemAlbums:(NSArray<AIQAlbum *> *)systemAlbums
                     customAlbums:(NSArray<AIQAlbum *> *)customAlbums;

- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)hideAnimated:(BOOL)animated;

@end
