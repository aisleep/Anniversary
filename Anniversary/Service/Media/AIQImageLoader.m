//
//  AIQImageLoader.m
//  Anniversary
//
//  Created by 小希 on 2017/8/31.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQImageLoader.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Extension.h"

@implementation AIQImageLoader

+ (UIImage *)nomarlPlaceholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageWithColor:MCSeperateColor];
    });
    return placeholderImage;
}

+ (void)setImageView:(UIImageView *)imageView imageURL:(NSURL *)imageURL {
    return [self setImageView:imageView imageURL:imageURL placeholderImage:[self nomarlPlaceholderImage]];
}


+ (void)setImageView:(UIImageView *)imageView imageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholder {
    return [self setImageView:imageView imageURL:imageURL placeholderImage:placeholder progress:nil completed:nil];
}

+ (void)setImageView:(UIImageView *)imageView imageURL:(NSURL *)imageURL progress:(AIQImageLoaderProgressBlock)progressBlock completed:(AIQImageLoaderCompletionBlock)completedBlock {
    return [self setImageView:imageView
                     imageURL:imageURL
             placeholderImage:[self nomarlPlaceholderImage]
                     progress:progressBlock
                    completed:completedBlock];
}

+ (void)setImageView:(UIImageView *)imageView imageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholder progress:(AIQImageLoaderProgressBlock)progressBlock completed:(AIQImageLoaderCompletionBlock)completedBlock {
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:placeholder
                          options:SDWebImageRetryFailed
                         progress:progressBlock
                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            if (error) {
                                DDLogError(@"[AIQImageLoader error]: %@", error);
                            }
                            if (completedBlock) {
                                completedBlock(image, error, imageURL);
                            }
                        }];
}

+ (void)loadImageWithURL:(NSURL *)imageURL progress:(AIQImageLoaderProgressBlock)progressBlock completed:(AIQImageLoaderCompletionBlock)completedBlock {
    [[SDWebImageManager sharedManager] loadImageWithURL:imageURL
                                                options:SDWebImageRetryFailed
                                               progress:progressBlock
                                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                  if (error) {
                                                      DDLogError(@"[AIQImageLoader error]: %@", error);
                                                  }
                                                  if (completedBlock) {
                                                      completedBlock(image, error, imageURL);
                                                  }
                                              }];
}

+ (void)setUpImageLoader {
    // Disk Cache
    [[[SDWebImageManager sharedManager] imageCache].config setMaxCacheSize:(200 * 1024 * 1024)];
    [[[SDWebImageManager sharedManager] imageCache].config setMaxCacheAge:604800];
    
    // 网络设置
    [SDWebImageDownloader sharedDownloader].downloadTimeout = 30;
    [SDWebImageDownloader sharedDownloader].maxConcurrentDownloads = 15;
    
    // @discuss 部分图片地址需要user-agent
    NSString *userAgent = @"";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [[SDWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
}

@end
