//
//  AIQAlbumSelectView.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQAlbumSelectView.h"
#import "AIQAlbum.h"

@interface AIQAlbumSelectView () <AIQTableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<AIQAlbum *> *systemAlbums;
@property (nonatomic, strong) NSArray<AIQAlbum *> *customAlbums;

@property (nonatomic, assign) CGFloat pointYForTransition;

@end

@implementation AIQAlbumSelectView

- (instancetype)initWithFrame:(CGRect)frame
                 systemAlbums:(NSArray<AIQAlbum *> *)systemAlbums
                 customAlbums:(NSArray<AIQAlbum *> *)customAlbums {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        _systemAlbums = systemAlbums;
        _customAlbums = customAlbums;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)showInViewController:(UIViewController *)controller animated:(BOOL)animated {
    _pointYForTransition = 0;
    if (controller.navigationController && !controller.navigationController.navigationBarHidden) {
        CGRect frame = controller.navigationController.navigationBar.frame;
        _pointYForTransition = CGRectGetMaxY(frame);
        self.contentInset = UIEdgeInsetsMake(_pointYForTransition, 0, 0, 0);
    }
    if (!animated) {
        [controller.view addSubview:self];
        return;
    }
    self.transform = CGAffineTransformMakeTranslation(0, -(self.bounds.size.height - _pointYForTransition));
    [controller.view addSubview:self];
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

#pragma mark - TableView DataSource && Delegate
- (NSArray<Class> *)classesForTableViewRegisterCell {
    return @[[AIQTableViewCell class]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
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
    AIQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[AIQTableViewCell reuseIdentifier] forIndexPath:indexPath];
    if (indexPath.section == 0) {
        AIQAlbum *album = [_systemAlbums objectAtIndex:indexPath.row];
        cell.textLabel.text = album.title;
    } else if (indexPath.section == 1) {
        AIQAlbum *album = [_customAlbums objectAtIndex:indexPath.row];
        cell.textLabel.text = album.title;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AIQAlbum *album = nil;
    if (indexPath.section == 0) {
        album = [_systemAlbums objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        album = [_customAlbums objectAtIndex:indexPath.row];
    }
    if (_selectAlbumHanler) {
        _selectAlbumHanler(album);
    }
    [self hideAnimated:YES];
}


@end
