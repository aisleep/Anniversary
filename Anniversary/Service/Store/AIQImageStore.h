//
//  AIQImageStore.h
//  Anniversary
//
//  Created by 小希 on 2017/9/12.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIQImageStore : NSObject

+ (void)storeImageToLocalStore:(UIImage *)image
                        forKey:(NSString *)key
                    completion:(void(^)())completion;

@end
