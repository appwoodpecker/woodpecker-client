//
//  DeviceUtil.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/6.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+ (NSString *)deviceName;
+ (NSString *)localIP;
+ (NSString *)localUSBIP;
+ (NSString *)hostName;

+ (void)pasteText: (NSString *)text;

/**
 * 判断当前语言是否为中文
 * 未测试
 */
+ (BOOL)isCN;

+ (NSString *)appVersion;

+ (BOOL)isOptionPressed;
+ (BOOL)isCmdPressed;

+ (BOOL)isSandboxed;
+ (BOOL)isDarkMode;

//util
+ (NSString *)getDeviceModel: (NSString *)deviceModel;

+ (NSString *)getDownloadPath;

@end
