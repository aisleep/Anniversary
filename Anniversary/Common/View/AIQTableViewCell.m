//
//  AIQTableViewCell.m
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQTableViewCell.h"

@implementation AIQTableViewHeaderFooterView

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
    }
    return _titleLabel;
}

@end

@implementation AIQTableViewCell {
    UIImageView *_disclosureIndicator;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImageView *)disclosureIndicator {
    if (!_disclosureIndicator) {
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_right"]];
    }
    return _disclosureIndicator;
}

- (void)setDisclosureIndicatorStyle:(AIQTableViewCellAccessoryStyle)style {
    switch (style) {
        case AIQTableViewCellAccessoryDarkStyle:
            _disclosureIndicator.image = [UIImage imageNamed:@"icon_arrow_right"];
            break;
        case AIQTableViewCellAccessoryLightStyle:
            _disclosureIndicator.image = [UIImage imageNamed:@"icon_arrow_right_w"];
            break;
        default:
            break;
    }
}

- (void)showDisclosureIndicator {
    self.accessoryView = self.disclosureIndicator;
}

- (void)hideDisclosureIndicator {
    self.accessoryView = nil;
}

@end
