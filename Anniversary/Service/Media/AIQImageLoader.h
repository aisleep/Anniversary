//
//  AIQImageLoader.h
//  Anniversary
//
//  Created by 小希 on 2017/8/31.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AIQImageLoaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

typedef void(^AIQImageLoaderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL);


@interface AIQImageLoader : NSObject

+ (void)setImageView:(UIImageView *)imageView
            imageURL:(NSURL *)imageURL;

+ (void)setImageView:(UIImageView *)imageView
            imageURL:(NSURL *)imageURL
    placeholderImage:(nullable UIImage *)placeholder;

+ (void)setImageView:(UIImageView *)imageView
            imageURL:(NSURL *)imageURL
            progress:(nullable AIQImageLoaderProgressBlock)progressBlock
           completed:(nullable AIQImageLoaderCompletionBlock)completedBlock;

+ (void)setImageView:(UIImageView *)imageView
            imageURL:(NSURL *)imageURL
    placeholderImage:(nullable UIImage *)placeholder
            progress:(nullable AIQImageLoaderProgressBlock)progressBlock
           completed:(nullable AIQImageLoaderCompletionBlock)completedBlock;

+ (void)loadImageWithURL:(NSURL *)imageURL
                progress:(nullable AIQImageLoaderProgressBlock)progressBlock
               completed:(nullable AIQImageLoaderCompletionBlock)completedBlock;


+ (void)setUpImageLoader;

@end

NS_ASSUME_NONNULL_END
