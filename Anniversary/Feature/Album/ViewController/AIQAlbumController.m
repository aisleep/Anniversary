//
//  AIQAlbumController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumController.h"
#import "AIQAlbumBrowser.h"

#import "AIQAlbumViewModel.h"

#import "AIQPhotoThumbnailCell.h"
#import "AIQAlbumSelectView.h"

static const CGFloat CellSpacing = 5.f;
static const CGFloat numberOfline = 4.f;

@interface AIQAlbumController () <AIQAlbumBrowserDelegate, AIQAlbumBrowserDataSource>

@property (nonatomic, strong) AIQAlbumBrowser *browser;

@property (nonatomic, strong) AIQAlbumViewModel *albumViewModel;

@property (nonatomic, strong) AIQAlbumSelectView *albumSelectView;
@property (nonatomic, strong) UIButton *titleView;
@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation AIQAlbumController

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemSize = PointPixelFloor((kScreenWidth - CellSpacing * (numberOfline + 1)) / numberOfline);
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
    flowLayout.sectionInset = UIEdgeInsetsMake(CellSpacing, CellSpacing, CellSpacing, CellSpacing);
    flowLayout.minimumLineSpacing = CellSpacing;
    flowLayout.minimumInteritemSpacing = CellSpacing;
    self = [self initWithCollectionViewLayout:flowLayout];
    if (self) {
        _albumViewModel = [[AIQAlbumViewModel alloc] initWithThumbnailSize:CGSizeMake(itemSize * kScreenScale, itemSize * kScreenScale)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_albumViewModel initializeAlbum:^(BOOL success) {
        if (!success) {
            return;
        }
        [self initializeTitleView];
        [self initializeToolBar];
        [self.albumViewModel fetchPhotosAtAlbum:self.albumViewModel.selectedAlbum completeHandler:^{
            [self.collectionNode reloadData];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_albumViewModel unloadPhotoImages];
    [_albumSelectView unloadAlbumCovers];
}

- (void)initializeTitleView {
    _titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleView.titleLabel.font = MCMainTitleFont;
    [_titleView setTitleColor:MCMainTitleColor forState:UIControlStateNormal];
    [_titleView addTarget:self action:@selector(showAlbumSelectView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleView;
    [self updateTitleView];
}

- (void)updateTitleView {
    AIQAlbum *album = _albumViewModel.selectedAlbum;
    UIButton *titleView =  (UIButton *)self.navigationItem.titleView;
    [titleView setTitle:album.title forState:UIControlStateNormal];
    [titleView sizeToFit];
}

- (void)initializeToolBar {
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:[UIApplication sharedApplication].statusBarOrientation]];
//    _toolbar.tintColor = [UIColor whiteColor];
    _toolbar.barTintColor = nil;
    [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
    _toolbar.barStyle = UIBarStyleDefault;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    if (_selectMode == AIQAlbumSelectModeSingle) {
        return;
    }
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    UIEdgeInsets inset = flowLayout.sectionInset;
    inset.bottom += _toolbar.frame.size.height;
    flowLayout.sectionInset = inset;
    self.collectionNode.view.scrollIndicatorInsets = inset;
    [self.node.view addSubview:_toolbar];
}

- (AIQAlbumSelectView *)albumSelectView {
    if (!_albumSelectView) {
        _albumSelectView = [[AIQAlbumSelectView alloc] initWithFrame:self.view.bounds
                                                        systemAlbums:_albumViewModel.systemAlbums
                                                        customAlbums:_albumViewModel.customAlbums];
        @weakify(self)
        _albumSelectView.selectAlbumHanler = ^(AIQAlbum *selectedAlbum) {
            @strongify(self)
            self.albumViewModel.selectedAlbum = selectedAlbum;
            [self updateTitleView];
            [self.albumViewModel fetchPhotosAtAlbum:selectedAlbum completeHandler:^{
                [self.collectionNode reloadData];
            }];
        };
    }
    return _albumSelectView;
}

#pragma mark - UIAction 
- (void)showAlbumSelectView {
    if (self.albumSelectView.superview) {
        [self.albumSelectView hideAnimated:YES];
    } else {
        [self.albumSelectView showInViewController:self animated:YES];
    }
}

- (void)showAlbumBrowserInCurrentPhotoIndex:(NSUInteger)index {
    if (_browser) {
        return;
    }
    CGRect screenFrame = self.view.bounds;
    _browser = [[AIQAlbumBrowser alloc] init];
    _browser.dataSource = self;
    _browser.delegate = self;
    _browser.customToolbar = _toolbar;
    [_browser setCurrentPhotoIndex:index];
    _browser.view.frame = CGRectOffset(_browser.view.frame, 0, -1 * screenFrame.size.height);
    
    // Add as a child view controller
    [self addChildViewController:_browser];
    [self.view addSubview:_browser.view];
    if (_toolbar.superview) {
        [self.view bringSubviewToFront:_toolbar];
    }
    
    // Perform any adjustments
    [_browser.view layoutIfNeeded];
    
    // NavigationItem
    self.navigationItem.titleView = nil;
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(hideAlbumBrowser)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    UIBarButtonItem *selectButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(commitSelectedImages)];
    // Animate grid in and photo scroller out
    self.navigationItem.rightBarButtonItem = selectButtonItem;
    [_browser willMoveToParentViewController:self];
    [UIView animateWithDuration:0.3 animations:^(void) {
        _browser.view.frame = screenFrame;
        self.collectionNode.frame = CGRectOffset(screenFrame, 0, 1 * screenFrame.size.height);
    } completion:^(BOOL finished) {
        [_browser didMoveToParentViewController:self];
    }];
}

- (void)hideAlbumBrowser {
    if (!_browser) {
        return;
    }
    
    // Remember previous content offset
    NSUInteger currentIndex = _browser.currentIndex;
    [self.collectionNode scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
    // Position prior to hide animation
    CGRect screenFrame = self.view.bounds;
    self.collectionNode.frame = CGRectOffset(screenFrame, 0, 1 * screenFrame.size.height);
    
    // Remember and remove controller now so things can detect a nil grid controller
    AIQAlbumBrowser *tmpBrowser = _browser;
    _browser = nil;
    
    // Update
    [self updateTitleView];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    // Animate, hide grid and show paging scroll view
    [UIView animateWithDuration:0.3 animations:^{
        tmpBrowser.view.frame = CGRectOffset(screenFrame, 0, -1 * screenFrame.size.height);
        self.collectionNode.frame = screenFrame;
        self.navigationItem.title = nil;
        self.navigationItem.titleView = self.titleView;
    } completion:^(BOOL finished) {
        [tmpBrowser willMoveToParentViewController:nil];
        [tmpBrowser.view removeFromSuperview];
        [tmpBrowser removeFromParentViewController];
    }];
}

#pragma mark Complete Select Image
- (void)commitSelectedImages {
    if (!_browser) {
        return;
    }
    if (_selectMode == AIQAlbumSelectModeSingle) {
        [_albumViewModel selectPhotoAtIndex:_browser.currentIndex];
    }
}

#pragma mark - dataSouce
- (NSInteger)numberOfPhoto {
    return _albumViewModel.numberOfPhoto;
}

- (id<MWPhoto>)photoAtIndex:(NSUInteger)index {
    if (index < [self numberOfPhoto]) {
        return [_albumViewModel.originalImageForSelectedAlbum objectAtIndex:index];
    }
    return nil;
}

- (id<MWPhoto>)thumbPhotoAtIndex:(NSUInteger)index {
    if (index < [self numberOfPhoto]) {
        return [_albumViewModel.thumbnailsForSelectedAlbum objectAtIndex:index];
    }
    return nil;
}

#pragma mark - CollectionView DataSource && Delegate
- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    return [self numberOfPhoto];
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    AIQPhoto *photo = [self thumbPhotoAtIndex:indexPath.item];
    return ^{
        AIQPhotoThumbnailCell *cell = [[AIQPhotoThumbnailCell alloc] init];
        [cell setPhoto:photo];
        return cell;
    };
}

- (void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showAlbumBrowserInCurrentPhotoIndex:indexPath.item];
}

- (BOOL)shouldBatchFetchForCollectionNode:(ASCollectionNode *)collectionNode {
    return NO;
}

#pragma mark - AIQAlbumBrowserDataSource
- (NSUInteger)numberOfPhotosInPhotoBrowser:(AIQAlbumBrowser *)photoBrowser {
    return [self numberOfPhoto];
}

- (id<MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self photoAtIndex:index];
}

- (id<MWPhoto>)photoBrowser:(AIQAlbumBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self thumbPhotoAtIndex:index];
}

#pragma mark - AIQAlbumBrowserDelegate
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser updateNavigationTitleAtIndex:(NSUInteger)index {
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", index + 1, _albumViewModel.numberOfPhoto];
}

- (BOOL)photoBrowser:(AIQAlbumBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [_albumViewModel isPhotoSelectedAtIndex:index];
}

- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    if (selected) {
        [_albumViewModel selectPhotoAtIndex:index];
    } else {
        [_albumViewModel removeSelectedPhotoAtIndex:index];
    }
}

- (void)photoBrowserDidFinishModalPresentation:(AIQAlbumBrowser *)photoBrowser {
    [self hideAlbumBrowser];
}

#pragma layout -
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
    return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

#pragma mark - Status Bar
- (BOOL)prefersStatusBarHidden {
    if (_browser) {
        return [_browser prefersStatusBarHidden];
    }
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

@end
