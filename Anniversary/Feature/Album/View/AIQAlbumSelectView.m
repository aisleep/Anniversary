//
//  AIQAlbumSelectView.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumSelectView.h"
#import "AIQViewController.h"
#import "AIQAlbum.h"
#import "AIQPhoto.h"

static const CGFloat CoverSize = 60.f;
static const CGFloat CellHeight = 70.f;

@interface AIQAlbumSelectCellVM : NSObject

@property (nonatomic, strong) AIQAlbum *album;
@property (nonatomic, strong) AIQPhoto *coverPhoto;

+ (instancetype)viewModelWithAlbum:(AIQAlbum *)album;

- (NSString *)albumName;
- (NSString *)photoCount;

@end

@implementation AIQAlbumSelectCellVM

+ (instancetype)viewModelWithAlbum:(AIQAlbum *)album {
    AIQAlbumSelectCellVM *vm = [[self alloc] init];
    vm.album = album;
    CGSize coverSize = CGSizeMake(CoverSize * kScreenScale, CoverSize * kScreenScale);
    vm.coverPhoto = [AIQPhoto photoWithAsset:album.coverAsset targetSize:coverSize];
    vm.coverPhoto.isThumbnail = YES;
    return vm;
}

- (NSString *)albumName {
    return _album.title;
}

- (NSString *)photoCount {
    return [NSString stringWithFormat:@"%ld", _album.photoCount];
}

@end

@interface AIQAlbumSelectSectionHeader : AIQTableViewHeaderFooterView

@end

@implementation AIQAlbumSelectSectionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel.font = [UIFont aiqSemiboldFontOfSize:17.f];
        self.titleLabel.textColor = MCSubTitleColor;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(kCellPadding);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-kCellPadding);
        }];
    }
    return self;
}


@end

@interface AIQAlbumSelectCell : AIQTableViewCell

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UILabel *photoCountLabel;

@property (nonatomic, strong) AIQAlbumSelectCellVM *vm;

@end

@implementation AIQAlbumSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self showDisclosureIndicator];
        _coverView = [[UIImageView alloc] init];
        _coverView.layer.cornerRadius = kDefaultCornerRadius;
        _coverView.layer.masksToBounds = YES;
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_coverView];
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.numberOfLines = 1;
        _albumNameLabel.font = [UIFont aiqSemiboldFontOfSize:15.f];
        _albumNameLabel.textColor = MCMainTitleColor;
        [self.contentView addSubview:_albumNameLabel];
        _photoCountLabel = [[UILabel alloc] init];
        _photoCountLabel.numberOfLines = 1;
        _photoCountLabel.font = [UIFont systemFontOfSize:15.f];
        _photoCountLabel.textColor = MCContentColor;
        [self.contentView addSubview:_photoCountLabel];
        
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CoverSize);
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(self.contentView).offset(kCellPadding);
        }];
        [_albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_coverView.mas_trailing).offset(15.f);
            make.top.equalTo(self.contentView).offset(12.f);
        }];
        [_photoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_albumNameLabel.mas_leading).offset(5);
            make.top.equalTo(_albumNameLabel.mas_bottom).offset(5);
        }];
        
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
    if (photo && photo == _vm.coverPhoto) {
        self.coverView.image = photo.underlyingImage;
    }
}

- (void)setVm:(AIQAlbumSelectCellVM *)vm {
    _vm = vm;
    if (_vm.coverPhoto.underlyingImage) {
        self.coverView.image = _vm.coverPhoto.underlyingImage;
    } else {
        [_vm.coverPhoto loadUnderlyingImageAndNotify];
    }
    _albumNameLabel.text = [_vm albumName];
    _photoCountLabel.text = [_vm photoCount];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _vm = nil;
    self.coverView.image = nil;
}

@end

@interface AIQAlbumSelectView () <AIQTableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<AIQAlbumSelectCellVM *> *systemAlbums;
@property (nonatomic, strong) NSArray<AIQAlbumSelectCellVM *> *customAlbums;

@property (nonatomic, assign) CGFloat pointYForTransition;

@end

@implementation AIQAlbumSelectView

- (instancetype)initWithFrame:(CGRect)frame
                 systemAlbums:(NSArray<AIQAlbum *> *)systemAlbums
                 customAlbums:(NSArray<AIQAlbum *> *)customAlbums {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        _systemAlbums = [self transformAlbumToAlbumSelectCellVM:systemAlbums];
        _customAlbums = [self transformAlbumToAlbumSelectCellVM:customAlbums];
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.rowHeight = CellHeight;
    }
    return self;
}

- (void)showInViewController:(AIQViewController *)controller animated:(BOOL)animated {
    _pointYForTransition = 0;
    if (controller.navigationController && !controller.navigationController.navigationBarHidden) {
        CGRect frame = controller.navigationController.navigationBar.frame;
        _pointYForTransition = CGRectGetMaxY(frame);
        self.contentInset = UIEdgeInsetsMake(_pointYForTransition, 0, 0, 0);
    }
    if (!animated) {
        [controller.node.view addSubview:self];
        return;
    }
    self.transform = CGAffineTransformMakeTranslation(0, -(self.bounds.size.height - _pointYForTransition));
    [controller.node.view addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideAnimated:(BOOL)animated {
    if (self.indexPathForSelectedRow) {
        [self deselectRowAtIndexPath:self.indexPathForSelectedRow animated:animated];
    }
    if (!animated) {
        [self removeFromSuperview];
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -(self.bounds.size.height - _pointYForTransition));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)unloadAlbumCovers {
    [_systemAlbums enumerateObjectsUsingBlock:^(AIQAlbumSelectCellVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.coverPhoto unloadUnderlyingImage];
    }];
    [_customAlbums enumerateObjectsUsingBlock:^(AIQAlbumSelectCellVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.coverPhoto unloadUnderlyingImage];
    }];
}


- (NSArray<AIQAlbumSelectCellVM *> *)transformAlbumToAlbumSelectCellVM:(NSArray<AIQAlbum *> *)ablums {
    NSMutableArray<AIQAlbumSelectCellVM *> *vms = [NSMutableArray arrayWithCapacity:ablums.count];
    [ablums enumerateObjectsUsingBlock:^(AIQAlbum * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AIQAlbumSelectCellVM *vm = [AIQAlbumSelectCellVM viewModelWithAlbum:obj];
        [vms addObject:vm];
    }];
    return vms.copy;
}

#pragma mark - TableView DataSource && Delegate
- (NSArray<Class> *)classesForTableViewRegisterCell {
    return @[[AIQAlbumSelectCell class]];
}

- (NSArray<Class> *)classesForTableViewRegisterHeaderFooterView {
    return @[[AIQAlbumSelectSectionHeader class]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _customAlbums.count ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _systemAlbums.count;
    }
    if (section == 1) {
        return _customAlbums.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AIQAlbumSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:[AIQAlbumSelectCell reuseIdentifier] forIndexPath:indexPath];
    AIQAlbumSelectCellVM *albumVM = nil;
    if (indexPath.section == 0) {
        albumVM = [_systemAlbums objectAtIndex:indexPath.row];
        
    } else if (indexPath.section == 1) {
        albumVM = [_customAlbums objectAtIndex:indexPath.row];
    }
    [cell setVm:albumVM];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kCellPadding;
    }
    return 45.f - kCellPadding;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kCellPadding;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    AIQAlbumSelectSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[AIQAlbumSelectSectionHeader reuseIdentifier]];
    header.titleLabel.text = @"我的相册";
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AIQAlbumSelectCellVM *albumVM = nil;
    if (indexPath.section == 0) {
        albumVM = [_systemAlbums objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        albumVM = [_customAlbums objectAtIndex:indexPath.row];
    }
    if (_selectAlbumHanler) {
        _selectAlbumHanler(albumVM.album);
    }
    [self hideAnimated:YES];
}

@end
