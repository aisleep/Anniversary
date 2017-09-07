//
//  AIQNetWorkSatusManager.h
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AIQNetworkStatus) {
    AIQNetworkStatusUnknown = -1,
    AIQNetworkStatusNotReachable  = 0,
    AIQNetworkStatusReachable2G = 1,
    AIQNetworkStatusReachable3G = 2,
    AIQNetworkStatusReachable4G = 3,
    AIQNetworkStatusReachable4GLater = 4,
    AIQNetworkStatusReachableWIFI= 10,
};

@interface AIQNetWorkSatusManager : NSObject

@property (nonatomic, assign, readonly) AIQNetworkStatus networkStatus;
@property (nonatomic, assign, readonly) AIQNetworkStatus radioAccessSatus;

+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (NSString *)networkStatusString;
- (NSString *)getIMSIAndStatusString;
- (BOOL)isReachable;
- (BOOL)is4GOrLater;
- (BOOL)isWifiReachable;
- (BOOL)isHighSpeedNetwork;
- (NSString *)getMccCode;

@end
