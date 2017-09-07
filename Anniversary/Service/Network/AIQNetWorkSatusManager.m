//
//  AIQNetWorkSatusManager.m
//  Anniversary
//
//  Created by 小希 on 2017/9/7.
//  Copyright © 2017年 小希. All rights reserved.
//

#import "AIQNetWorkSatusManager.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface AIQNetWorkSatusManager ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@property (nonatomic, strong) NSArray *radioAccess2GList;
@property (nonatomic, strong) NSArray *radioAccess3GList;
@property (nonatomic, strong) NSArray *radioAccess4GList;
@property (nonatomic, strong) NSDictionary *statusMap;

@end

@implementation AIQNetWorkSatusManager

+ (instancetype)sharedInstance {
    static id s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance= [[self alloc] init];
    });
    return s_instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        
        _networkInfo = [CTTelephonyNetworkInfo new];
        _radioAccess2GList = @[CTRadioAccessTechnologyEdge,
                               CTRadioAccessTechnologyGPRS];
        _radioAccess3GList = @[CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
        _radioAccess4GList = @[CTRadioAccessTechnologyLTE];
        
        _statusMap = @{@(AIQNetworkStatusUnknown) :  @"UNKNOWN",
                       @(AIQNetworkStatusNotReachable) : @"NoNet",
                       @(AIQNetworkStatusReachable2G) : @"2G",
                       @(AIQNetworkStatusReachable3G) : @"3G",
                       @(AIQNetworkStatusReachable4G) : @"4G",
                       @(AIQNetworkStatusReachable4GLater) : @"4G",
                       @(AIQNetworkStatusReachableWIFI) : @"WIFI"};
        
        _networkStatus = [self realNetworkStatus];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChangeNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

- (AIQNetworkStatus)realNetworkStatus {
    AFNetworkReachabilityStatus networkStatus = [_reachabilityManager networkReachabilityStatus];
    AIQNetworkStatus realNetworkStatus = AIQNetworkStatusUnknown;
    switch (networkStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            realNetworkStatus = AIQNetworkStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            realNetworkStatus = [self radioAccessSatus];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            realNetworkStatus = AIQNetworkStatusNotReachable;
            break;
        default:
            break;
    }
    return realNetworkStatus;
}

- (AIQNetworkStatus)radioAccessSatus {
    NSString *currentRadioAccess = self.networkInfo.currentRadioAccessTechnology;
    AIQNetworkStatus radioAccessSatus = AIQNetworkStatusUnknown;
    if ([_radioAccess2GList containsObject:currentRadioAccess]) {
        radioAccessSatus = AIQNetworkStatusReachable2G;
    } else if ([_radioAccess3GList containsObject:currentRadioAccess]) {
        radioAccessSatus = AIQNetworkStatusReachable3G;
    } else if ([_radioAccess4GList containsObject:currentRadioAccess]) {
        radioAccessSatus = AIQNetworkStatusReachable4G;
    } else {
        radioAccessSatus = AIQNetworkStatusReachable4GLater;
    }
    return radioAccessSatus;
}

- (void)startMonitoring {
    [_reachabilityManager startMonitoring];
}

- (void)stopMonitoring {
    [_reachabilityManager stopMonitoring];
}

- (NSString *)networkStatusString {
    return [self networkStatusText:_networkStatus];
}

- (NSString *)getIMSIAndStatusString{
    
    NSString *statusString = [self networkStatusString];
    //    if([statusString isEqualToString:@"WIFI"]){
    //        return statusString;
    //    }
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    
    return [NSString stringWithFormat:@"%@-%@",imsi, statusString];
}

- (BOOL)isWifiReachable {
    return self.networkStatus == AIQNetworkStatusReachableWIFI;
}

- (BOOL)is4GOrLater {
    return self.networkStatus == AIQNetworkStatusReachable4G || self.networkStatus == AIQNetworkStatusReachable4GLater;
}

- (BOOL)isReachable {
    return self.reachabilityManager.isReachable;
}

- (BOOL)isHighSpeedNetwork {
    BOOL flag = (/*self.networkStatus == MCNetworkStatusReachable3G ||*/
                 self.networkStatus == AIQNetworkStatusReachable4G ||
                 self.networkStatus == AIQNetworkStatusReachable4GLater ||
                 self.networkStatus == AIQNetworkStatusReachableWIFI  );
    return flag;
}

- (NSString *)networkStatusText:(AIQNetworkStatus)status {
    NSString *text = _statusMap[@(status)];
#if TARGET_IPHONE_SIMULATOR
    text = text ? text : @"WIFI";
#else
    text = text ? text : @"UNKNOWN";
#endif
    return text;
}

- (NSString *)getMccCode{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    
    return mcc;
}

#pragma mark - Notification 
- (void)reachabilityDidChangeNotification:(NSNotification *)notify {
    NSString *lastStatus = [self networkStatusText:_networkStatus];
    _networkStatus = [self realNetworkStatus];
    NSString *newStatus = [self networkStatusText:_networkStatus];
    DDLogInfo(@"[网络切换] %@ -> %@", lastStatus, newStatus);
}


@end
