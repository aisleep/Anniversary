//
//  AIQZoomingScrollView.h
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <AsyncDisplayKit/ASScrollNode.h>
#import "MWPhotoProtocol.h"
#import "AIQTapDetectingImageNode.h"
#import "MWTapDetectingView.h"

@class AIQAlbumBrowser;

@interface AIQZoomingScrollView : ASScrollNode <UIScrollViewDelegate, AIQTapDetectingImageNodeDelegate, MWTapDetectingViewDelegate>

@property () NSUInteger index;
@property (nonatomic) id <MWPhoto> photo;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;

- (instancetype)initWithPhotoBrowser:(AIQAlbumBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end
