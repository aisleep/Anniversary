//
//  AIQPhotoThumbnailCell.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQPhotoThumbnailCell.h"
#import "AIQPhoto.h"

@interface AIQPhotoThumbnailCell ()

@property (nonatomic, strong) ASImageNode *playIcon;

@end

@implementation AIQPhotoThumbnailCell

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageNode.contentMode = UIViewContentModeScaleAspectFill;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeLoadImageNotification:) name:MWPHOTO_IMMEDIATELYREFRESHING_NOTIFICATION object:nil];;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)completeLoadImageNotification:(NSNotification *)notify {
    AIQPhoto *photo = notify.object;
    if (photo && photo == _photo) {
        self.imageNode.image = photo.underlyingImage;
    }
}

- (void)setPhoto:(AIQPhoto *)photo {
    _photo = photo;
    if (photo.underlyingImage) {
        self.imageNode.image = photo.underlyingImage;
    } else {
        [self onDidLoad:^(__kindof ASDisplayNode * _Nonnull node) {
            [_photo loadUnderlyingImageAndNotify];
        }];
    }
    if (_photo.isVideo) {
        self.playIcon.hidden = NO;
    }
}

- (ASImageNode *)playIcon {
    if (!_playIcon) {
        _playIcon = [[ASImageNode alloc] init];
        _playIcon.image = [UIImage imageNamed:@"btn_videoplay_m"];
        [self addSubnode:_playIcon];
        _playIcon.position = self.position;
    }
    return _playIcon;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.imageNode.frame = self.bounds;
}

@end
