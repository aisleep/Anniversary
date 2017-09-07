//
//  AIQPhoto.m
//  Anniversary
//
//  Created by 小希 on 2017/9/1.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQPhoto.h"
#import <Photos/Photos.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDWebImageOperation.h>

@interface AIQPhoto () {
    
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
    PHImageRequestID _assetRequestID;
    PHImageRequestID _assetVideoRequestID;
    UIImage *_underlyingImage;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic) CGSize assetTargetSize;

@property (nonatomic, assign) BOOL isLoadingImage;

@end

@implementation AIQPhoto

+ (instancetype)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    return [[self alloc] initWithAsset:asset targetSize:targetSize];
}

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    self = [self init];
    if (self) {
        _asset = asset;
        _assetTargetSize = targetSize;
        _isVideo = self.isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        _localIdentifier = asset.localIdentifier;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _assetRequestID = PHInvalidImageRequestID;
    _assetVideoRequestID = PHInvalidImageRequestID;
}

- (void)dealloc {
    [self cancelAnyLoading];
}

#pragma mark - Video
- (void)getVideoURL:(void (^)(NSURL *))completion {
    [self cancelVideoRequest]; // Cancel any existing
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.networkAccessAllowed = YES;
    @weakify(self);
    _assetVideoRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        @strongify(self)
        if (!self) return;
        self->_assetVideoRequestID = PHInvalidImageRequestID;
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            completion(((AVURLAsset *)asset).URL);
        } else {
            completion(nil);
        }
    }];
}

#pragma mark - Load Image
- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        _isInCloud = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
//        // Check what type of url it is
       if ([_photoURL isFileReferenceURL]) {
            
            // Load from local file async
            [self _performLoadUnderlyingImageAndNotifyWithLocalFileURL: _photoURL];
            
        } else {
            
            // Load async from web (using SDWebImage)
            [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
            
        }
        
    } else if (_asset) {
        
        // Load from photos asset
        if (_isThumbnail) {
            [self _performLoadThumbnailAndNotifyWithAsset:_asset targetSize:_assetTargetSize];
        } else {
            [self _performLoadUnderlyingImageAndNotifyWithAsset:_asset targetSize:_assetTargetSize];
        }
        
    } else {
        
        // Image is empty
        [self imageLoadingComplete];
        
    }
}

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithLocalFileURL:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                self.underlyingImage = [UIImage imageWithContentsOfFile:url.path];
                if (!_underlyingImage) {
                    DDLogError(@"Error loading photo from path: %@", url.path);
                }
            } @finally {
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

// Load from web URL
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager loadImageWithURL:url
                                               options:SDWebImageRetryFailed
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                  if (expectedSize > 0) {
                                                      float progress = receivedSize / (float)expectedSize;
                                                      NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                            [NSNumber numberWithFloat:progress], @"progress",
                                                                            self, @"photo", nil];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                                  }
                                              }
                                             completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                 if (error) {
                                                     DDLogError(@"SDWebImage failed to download image: %@", error);
                                                 }
                                                 _webImageOperation = nil;
                                                 self.underlyingImage = image;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self imageLoadingComplete];
                                                 });
                                             }];
    } @catch (NSException *e) {
        DDLogError(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self imageLoadingComplete];
    }
}

// Load from photos library
- (void)_performLoadUnderlyingImageAndNotifyWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble: progress], MWPHOTO_NOTIFICATION_INFOKEY_PROGRESS,
                              self, MWPHOTO_NOTIFICATION_INFOKEY_PHOTO, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
    };
    _assetRequestID = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.underlyingImage = result;
            [self imageLoadingComplete];
        });
    }];
}

- (void)_performLoadThumbnailAndNotifyWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = NO;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = NO;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble: progress], MWPHOTO_NOTIFICATION_INFOKEY_PROGRESS,
                              self, MWPHOTO_NOTIFICATION_INFOKEY_PHOTO, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
    };
    _assetRequestID = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
            self.underlyingImage = result;
            [self imageLoadingComplete];
        });
    }];
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    _assetRequestID = PHInvalidImageRequestID;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
    // Notify on current run loop
    [self performSelectorOnMainThread:@selector(postImmediatelyRefreshingNotification) withObject:nil waitUntilDone:NO];
    
}

- (void)postImmediatelyRefreshingNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_IMMEDIATELYREFRESHING_NOTIFICATION
                                                        object:self];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    _isInCloud = NO;
    self.underlyingImage = nil;
}

- (void)cancelAnyLoading {
    _loadingInProgress = NO;
    _isInCloud = NO;
    if (_webImageOperation != nil) {
        [_webImageOperation cancel];
    }
    [self cancelImageRequest];
    [self cancelVideoRequest];
}

- (void)cancelImageRequest {
    if (_assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetRequestID];
        _assetRequestID = PHInvalidImageRequestID;
    }
}

- (void)cancelVideoRequest {
    if (_assetVideoRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_assetVideoRequestID];
        _assetVideoRequestID = PHInvalidImageRequestID;
    }
}

@end
