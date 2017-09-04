//
//  AIQAlbum.h
//  Anniversary
//
//  Created by 小希 on 2017/9/4.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAssetCollection;
@interface AIQAlbum : NSObject

@property (nonatomic, copy) NSString *localIdentifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSUInteger photoCount;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
