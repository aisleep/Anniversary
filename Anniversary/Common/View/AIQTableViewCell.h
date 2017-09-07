//
//  AIQTableViewCell.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AIQTableViewCellAccessoryStyle) {
    AIQTableViewCellAccessoryDarkStyle,
    AIQTableViewCellAccessoryLightStyle
};

NS_ASSUME_NONNULL_BEGIN

@interface AIQTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;

+ (NSString *)reuseIdentifier;

@end

@interface AIQTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, readonly) UIImageView *disclosureIndicator;
- (void)setDisclosureIndicatorStyle:(AIQTableViewCellAccessoryStyle)style;
- (void)showDisclosureIndicator;
- (void)hideDisclosureIndicator;

@end

NS_ASSUME_NONNULL_END
