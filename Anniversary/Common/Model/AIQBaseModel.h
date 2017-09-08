//
//  AIQBaseModel.h
//  Anniversary
//
//  Created by 小希 on 2017/9/8.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIQBaseModel : NSObject <NSSecureCoding>

//skip instance Invar's key (if contain '_' must include it)
- (nullable NSArray <NSString *>*)skipCodingIvarKeys;

@end

NS_ASSUME_NONNULL_END
