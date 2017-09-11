//
//  AIQZoomingScrollView.m
//  Anniversary
//
//  Created by 小希 on 2017/9/9.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <DACircularProgress/DACircularProgressView.h>
#import "AIQZoomingScrollView.h"
#import "AIQAlbumBrowser_Private.h"

@interface AIQZoomingScrollView () {
    
    AIQAlbumBrowser __weak *_photoBrowser;
    MWTapDetectingView *_tapView; // for background taps
    AIQTapDetectingImageNode *_photoImageView;
    DACircularProgressView *_loadingIndicator;
    UIImageView *_loadingError;
}

@end

@implementation AIQZoomingScrollView

- (instancetype)initWithPhotoBrowser:(AIQAlbumBrowser *)browser {
    if ((self = [super init])) {
        // Setup
        _index = NSUIntegerMax;
        _photoBrowser = browser;
        // Image view
        _photoImageView = [[AIQTapDetectingImageNode alloc] init];
        _photoImageView.tapDelegate = self;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _photoImageView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)didLoad {
    [super didLoad];

    // Tap view for background
    _tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
    _tapView.tapDelegate = self;
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tapView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_tapView];

    [self addSubnode:_photoImageView];
    
    // Loading indicator
    _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
    _loadingIndicator.userInteractionEnabled = NO;
    _loadingIndicator.thicknessRatio = 0.1;
    _loadingIndicator.roundedCorners = NO;
    _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_loadingIndicator];
    
    // Listen progress notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setProgressFromNotification:)
                                                 name:MWPHOTO_PROGRESS_NOTIFICATION
                                               object:nil];
    
    // Setup
    self.backgroundColor = [UIColor blackColor];
    self.view.delegate = self;
    self.view.showsHorizontalScrollIndicator = NO;
    self.view.showsVerticalScrollIndicator = NO;
    self.view.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)dealloc {
    if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
        [_photo cancelAnyLoading];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [self hideImageFailure];
    self.photo = nil;
    self.selectedButton = nil;
    self.playButton = nil;
    _photoImageView.hidden = NO;
    _photoImageView.image = nil;
    _index = NSUIntegerMax;
}

- (BOOL)displayingVideo {
    return [_photo respondsToSelector:@selector(isVideo)] && _photo.isVideo;
}

- (void)setImageHidden:(BOOL)hidden {
    _photoImageView.hidden = hidden;
}

#pragma mark - Image

- (void)setPhoto:(id<MWPhoto>)photo {
    // Cancel any loading on old photo
    if (_photo && photo == nil) {
        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photo cancelAnyLoading];
        }
    }
    _photo = photo;
    UIImage *img = [_photoBrowser imageForPhoto:_photo];
    if (img) {
        [self displayImage];
    } else {
        // Will be loading so show loading
        [self showLoadingIndicator];
    }
}

// Get and display image
- (void)displayImage {
    if (_photo && _photoImageView.image == nil) {
        
        // Reset
        self.view.maximumZoomScale = 1;
        self.view.minimumZoomScale = 1;
        self.view.zoomScale = 1;
        self.view.contentSize = CGSizeMake(0, 0);
        
        // Get image from browser as it handles ordering of fetching
        UIImage *img = [_photoBrowser imageForPhoto:_photo];
        if (img) {
            
            // Hide indicator
            [self hideLoadingIndicator];
            
            // Set image
            _photoImageView.image = img;
            _photoImageView.hidden = NO;
            
            // Setup photo frame
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = img.size;
            _photoImageView.view.frame = photoImageViewFrame;
            self.view.contentSize = photoImageViewFrame.size;
            
            // Set zoom to minimum zoom
            [self setMaxMinZoomScalesForCurrentBounds];
            
        } else  {
            
            // Show image failure
            [self displayImageFailure];
            
        }
        [self setNeedsLayout];
    }
}

// Image failed so just show black!
- (void)displayImageFailure {
    [self hideLoadingIndicator];
    _photoImageView.image = nil;
    
    // Show if image is not empty
    if (![_photo respondsToSelector:@selector(emptyImage)] || !_photo.emptyImage) {
        if (!_loadingError) {
            _loadingError = [UIImageView new];
            _loadingError.image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageError" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
            _loadingError.userInteractionEnabled = NO;
            _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingError sizeToFit];
            [self.view addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    }
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

#pragma mark - Loading Progress

- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        id <MWPhoto> photoWithProgress = [dict objectForKey:@"photo"];
        if (photoWithProgress == self.photo) {
            float progress = [[dict valueForKey:@"progress"] floatValue];
            _loadingIndicator.progress = MAX(MIN(1, progress), 0);
        }
    });
}

- (void)hideLoadingIndicator {
    _loadingIndicator.hidden = YES;
}

- (void)showLoadingIndicator {
    self.view.zoomScale = 0;
    self.view.minimumZoomScale = 0;
    self.view.maximumZoomScale = 0;
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    [self hideImageFailure];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
//    CGFloat zoomScale = self.view.minimumZoomScale;
//    if (_photoImageView && _photoBrowser.zoomPhotosToFill) {
//        // Zoom image to fill if the aspect ratios are fairly similar
//        CGSize boundsSize = self.bounds.size;
//        CGSize imageSize = _photoImageView.image.size;
//        CGFloat boundsAR = boundsSize.width / boundsSize.height;
//        CGFloat imageAR = imageSize.width / imageSize.height;
//        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
//        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
//        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
//        if (ABS(boundsAR - imageAR) < 0.17) {
//            zoomScale = MAX(xScale, yScale);
//            // Ensure we don't zoom in or out too far, just in case
//            zoomScale = MIN(MAX(self.view.minimumZoomScale, zoomScale), self.view.maximumZoomScale);
//        }
//    }
//    return zoomScale;
    return self.view.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.view.maximumZoomScale = 1;
    self.view.minimumZoomScale = 1;
    self.view.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.view.frame = CGRectMake(0, 0, _photoImageView.view.frame.size.width, _photoImageView.view.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
//    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
//    

    CGFloat minScale = xScale;
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.view.maximumZoomScale = maxScale;
    self.view.minimumZoomScale = minScale;
    
    // Initial zoom
    self.view.zoomScale = [self initialZoomScaleWithMinScale];

    // If we're zooming to fill then centralise
    if (self.view.zoomScale != minScale) {
        
        // Centralise
        self.view.contentOffset = CGPointMake((imageSize.width * self.view.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.view.zoomScale - boundsSize.height) / 2.0);
        
    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
//    self.view.scrollEnabled = NO;
    
    // If it's a video then disable zooming
    if ([self displayingVideo]) {
        self.view.maximumZoomScale = self.view.zoomScale;
        self.view.minimumZoomScale = self.view.zoomScale;
    }
    
}

#pragma mark - Layout

- (void)layoutDidFinish {
    [super layoutDidFinish];
    
    // Update tap view frame
    _tapView.frame = self.bounds;
    
    // Position indicators (centre does not seem to work!)
    if (!_loadingIndicator.hidden)
        _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                             _loadingIndicator.frame.size.width,
                                             _loadingIndicator.frame.size.height);
    if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
   
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.view.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.view.frame, frameToCenter))
        _photoImageView.view.frame = frameToCenter;
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView.view;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.view.scrollEnabled = YES; // reset
    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_photoBrowser hideControlsAfterDelay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Dont double tap to zoom if showing a video
    if ([self displayingVideo]) {
        return;
    }
    
    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    
    // Zoom
    if (self.view.zoomScale != self.view.minimumZoomScale && self.view.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self.view setZoomScale:self.view.minimumZoomScale animated:YES];
        
    } else {
        
        // Zoom in to twice the size
//        CGFloat newZoomScale = ((self.view.maximumZoomScale + self.view.minimumZoomScale) / 2);
        CGFloat newZoomScale = self.view.minimumZoomScale * 2;
        
        CGSize imageSize = _photoImageView.image.size;
        if (imageSize.width > imageSize.height) {
            newZoomScale = self.bounds.size.height / imageSize.height;
        }
        
        
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self.view zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        
    }
    
    // Delay controls
    [_photoBrowser hideControlsAfterDelay];
    
}

// Image View
- (void)imageNode:(ASImageNode *)imageNode singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageNode.view]];
}
- (void)imageNode:(ASImageNode *)imageNode doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageNode.view]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.view.zoomScale;
    touchY *= 1/self.view.zoomScale;
    touchX += self.view.contentOffset.x;
    touchY += self.view.contentOffset.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.view.zoomScale;
    touchY *= 1/self.view.zoomScale;
    touchX += self.view.contentOffset.x;
    touchY += self.view.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

@end