//
//  AIQAlbumController.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumController.h"

#import "AIQAlbumViewModel.h"

#import "AIQPhotoThumbnailCell.h"
#import "AIQAlbumSelectView.h"


@interface AIQAlbumController ()

@property (nonatomic, strong) AIQAlbumViewModel *albumViewModel;

@property (nonatomic, strong) AIQAlbumSelectView *albumSelectView;

@end

@implementation AIQAlbumController

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemSize = (kScreenWidth - kCellPadding * 3) / 4;
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
    flowLayout.sectionInset = UIEdgeInsetsMake(kCellPadding, 0, 0, 0);
    flowLayout.minimumLineSpacing = kCellPadding;
    flowLayout.minimumInteritemSpacing = kCellPadding;
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
- (NSArray<Class> *)classesForTableViewRegisterCell {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
