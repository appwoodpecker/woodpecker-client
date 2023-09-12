//
//  ADHApp.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlatformDefines.h"


@class ADHApiClient;
@class ADHUsb;
@interface ADHApp : NSObject

@property (nonatomic, strong) ADHApiClient *apiClient;
@property (nonatomic, strong) ADHProtocol *protocol;
@property (nonatomic, strong) NSString * host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) NSString * deviceName;
@property (nonatomic, strong) NSString * bundleId;
@property (nonatomic, strong) NSString * appName;
@property (nonatomic, strong) NSString * systemVersion;
@property (nonatomic, assign) ADHPlatform platform;
@property (nonatomic, assign, getter=isSandboxed) BOOL sandbox;
@property (nonatomic, assign, getter=isSimulator) BOOL simulator;
@property (nonatomic, weak) ADHUsb *usb;

//App特有工具集
@property (nonatomic, strong) NSArray *appToolList;

//更多app信息
@property (nonatomic, strong) NSDictionary *appInfo;

@property (nonatomic, strong) NSString * frameworkVersion;

@property (nonatomic, strong) NSString *shakeId;

//本地工作路径
- (NSString *)basePath;
- (BOOL)isValid;

//major version
- (NSInteger)majorVersion;
//minor version
- (NSInteger)minorVersion;

//framework版本号
- (NSInteger)frameworkVersionValue;

- (BOOL)isMacOS;
- (BOOL)isAndroid;
- (BOOL)isUSB;
- (NSNumber *)usbDeviceId;

@end
