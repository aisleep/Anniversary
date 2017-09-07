//
//  AIQAlbumController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumController.h"
#import "MWPhotoBrowser.h"

#import "AIQAlbumViewModel.h"

#import "AIQPhotoThumbnailCell.h"
#import "AIQAlbumSelectView.h"

static const CGFloat CellSpacing = 5.f;
static const CGFloat numberOfline = 4.f;

@interface AIQAlbumController () <MWPhotoBrowserDelegate>

@property (nonatomic, strong) AIQAlbumViewModel *albumViewModel;

@property (nonatomic, strong) AIQAlbumSelectView *albumSelectView;

@end

@implementation AIQAlbumController

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemSize = (kScreenWidth - CellSpacing * (numberOfline + 1)) / numberOfline;
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
            [self.collectionView reloadData];
        }];
    }];
}

- (void)initializeTitleView {
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleView setTitleColor:MCMainTitleColor forState:UIControlStateNormal];
    [titleView addTarget:self action:@selector(showAlbumSelectView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleView;
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
                [self.collectionView reloadData];
            }];
        };
    }
    return _albumSelectView;
}

#pragma mark - UIAction 
- (void)showAlbumSelectView {
    [self.albumSelectView showInViewController:self animated:YES];
}

#pragma mark - CollectionView DataSource && Delegate
- (NSArray<Class> *)classesForCollectionViewRegisterCell {
    return @[[AIQPhotoThumbnailCell class]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumViewModel.thumbnailsForSelectedAlbum.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AIQPhotoThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[AIQPhotoThumbnailCell reuseIdentifier]forIndexPath:indexPath];
    if (indexPath.item < _albumViewModel.thumbnailsForSelectedAlbum.count) {
        AIQPhoto *photo = [_albumViewModel.thumbnailsForSelectedAlbum objectAtIndex:indexPath.item];
        [cell setPhoto:photo];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser setCurrentPhotoIndex:indexPath.item];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _albumViewModel.originalImageForSelectedAlbum.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    AIQPhoto *photo = [_albumViewModel.originalImageForSelectedAlbum objectAtIndex:index];
    return photo;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    AIQPhoto *photo = [_albumViewModel.thumbnailsForSelectedAlbum objectAtIndex:index];
    return photo;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_albumViewModel unloadThumbnails];
    [_albumSelectView unloadAlbumCovers];
}

@end
