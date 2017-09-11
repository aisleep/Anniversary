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

@interface AIQAlbumController () <AIQAlbumBrowserDelegate>

@property (nonatomic, strong) AIQAlbumBrowser *browser;

@property (nonatomic, strong) AIQAlbumViewModel *albumViewModel;

@property (nonatomic, strong) AIQAlbumSelectView *albumSelectView;
@property (nonatomic, strong) UIButton *titleView;


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
    _browser.dataSource = _albumViewModel;
    _browser.delegate = self;
    [_browser setCurrentPhotoIndex:index];
    _browser.view.frame = CGRectOffset(_browser.view.frame, 0, -1 * screenFrame.size.height);
    
    // Add as a child view controller
    [self addChildViewController:_browser];
    [self.view addSubview:_browser.view];
    
    // Perform any adjustments
    [_browser.view layoutIfNeeded];
    
    // Hide action button on nav bar if it exists
//    if (self.navigationItem.rightBarButtonItem == _actionButton) {
//        _gridPreviousRightNavItem = _actionButton;
//        [self.navigationItem setRightBarButtonItem:nil animated:YES];
//    } else {
//        _gridPreviousRightNavItem = nil;
//    }
    self.navigationItem.titleView = nil;

    
    // Animate grid in and photo scroller out
    
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
    
    // Restore action button if it was removed
//    if (_gridPreviousRightNavItem == _actionButton && _actionButton) {
//        [self.navigationItem setRightBarButtonItem:_gridPreviousRightNavItem animated:YES];
//    }
    
    // Position prior to hide animation
    CGRect screenFrame = self.view.bounds;
    self.collectionNode.frame = CGRectOffset(screenFrame, 0, 1 * screenFrame.size.height);
    
    // Remember and remove controller now so things can detect a nil grid controller
    AIQAlbumBrowser *tmpBrowser = _browser;
    _browser = nil;
    
    // Update
    [self updateTitleView];
    
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

#pragma mark - CollectionView DataSource && Delegate
- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    return _albumViewModel.numberOfPhoto;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    AIQPhoto *photo = [_albumViewModel.thumbnailsForSelectedAlbum objectAtIndex:indexPath.item];
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

#pragma mark - AIQAlbumBrowserDelegate
- (void)photoBrowser:(AIQAlbumBrowser *)photoBrowser updateNavigationTitleAtIndex:(NSUInteger)index {
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", index + 1, _albumViewModel.numberOfPhoto];
}

- (void)photoBrowserDidFinishModalPresentation:(AIQAlbumBrowser *)photoBrowser {
    [self hideAlbumBrowser];
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
