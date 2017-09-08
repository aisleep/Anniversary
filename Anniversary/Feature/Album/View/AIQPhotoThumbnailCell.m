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

@property (nonatomic, strong) UIImageView *playIcon;

@end

@implementation AIQPhotoThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
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
        self.imageView.image = photo.underlyingImage;
    }
}

- (void)setPhoto:(AIQPhoto *)photo {
    _photo = photo;
    if (photo.underlyingImage) {
        self.imageView.image = photo.underlyingImage;
    } else {
        [_photo loadUnderlyingImageAndNotify];
    }
    if (_photo.isVideo) {
        self.playIcon.hidden = NO;
    }
}

- (UIImageView *)playIcon {
    if (!_playIcon) {
        _playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_videoplay_m"]];
        [self.contentView addSubview:_playIcon];
        [_playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return _playIcon;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _photo = nil;
    self.imageView.image = nil;
    _playIcon.hidden = YES;
}

@end
