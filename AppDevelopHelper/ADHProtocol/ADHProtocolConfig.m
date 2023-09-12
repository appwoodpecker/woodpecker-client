//
//  ADHProtocolConfig.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHProtocolConfig.h"

//32Kb
NSInteger const kADHPackagePayloadSize = 32 * 1024;
NSString * const kADHNetServiceDomain = @"local.";
NSString * const kADHNetServiceType = @"_adhp._tcp.";
NSString * const kADHNetServiceName = @"Woodpecker";

NSInteger const kADHProtocolListenTag = -100;

//单个包10s超时，对于在同一个wifi下连接的服务超时足够了
NSTimeInterval const kADHProtocolPackageTimeout = 10;

NSString * const kADHErrorDomain = @"ADH";

NSInteger const kADHErrorCodeTimeOut = -1000;

//USB
int const kADHUsbPort = 9999;
uint32_t const kADHUsbFrameTypeShake = 100;
uint32_t const kADHUsbFrameTypeData = 101;

NSTimeInterval const kADHUsbReconnectDelay = 0.8;

@implementation ADHProtocolConfig

+ (ADHProtocolConfig *)config {
    static dispatch_once_t onceToken;
    static ADHProtocolConfig * sharedConfig;
    dispatch_once(&onceToken, ^{
        sharedConfig = [[ADHProtocolConfig alloc] init];
    });
    return sharedConfig;
}


@end
