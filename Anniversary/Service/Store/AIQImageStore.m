//
//  AIQImageStore.m
//  Anniversary
//
//  Created by 小希 on 2017/9/12.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQImageStore.h"
#import <SDWebImage/SDImageCache.h>

@implementation AIQImageStore

static SDImageCache *localImageCache() {
    static dispatch_once_t onceToken;
    static SDImageCache *localImageCache = nil;
    dispatch_once(&onceToken, ^{
        localImageCache = [SDImageCache alloc];
        NSString *directory = [localImageCache makeDiskCachePath:@"defult"];
        localImageCache = [localImageCache initWithNamespace:@"localImageStore" diskCacheDirectory:directory];
        localImageCache.config.shouldCacheImagesInMemory = NO;
        localImageCache.config.maxCacheAge = 0;
    });
    return localImageCache;
}

static SDImageCache *webImageCache() {
    return [SDImageCache sharedImageCache];
}


+ (void)storeImageToLocalStore:(UIImage *)image
                        forKey:(NSString *)key
                    completion:(void (^)())completion {
    [localImageCache() storeImage:image forKey:key completion:completion];
}


@end
