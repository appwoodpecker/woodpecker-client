//
//  Preference.h
//  WoodPecker
//
//  Created by 张小刚 on 2018/1/5.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preference : NSObject

//默认工具
+ (void)saveToolItem: (NSArray *)toolIdentifiers;
+ (NSArray *)toolIdentifiers;

//debug
+ (void)clearTools;


+ (void)setWelcomePageShowd: (BOOL)showed;
+ (BOOL)welcomePageShowed;

//标记用户当前版本(用于更新提示)
+ (void)setLatestVersion: (NSString *)version;
+ (NSString *)latestVersion;

//BETA
+ (NSDate *)betaStartDate;
+ (void)setBetaStartDate: (NSDate *)date;
//beta版本有效时间，30天
+ (NSTimeInterval)betaLifeInterval;

+ (void)setDefaultValue: (id)value forKey: (NSString *)key inDomain: (NSString *)domain;
+ (id)defaultValueForKey: (NSString *)key inDomain: (NSString *)domain;

//启动次数
+ (void)addLaunchTimes;
+ (void)resetLaunchTimes;
+ (NSInteger)getLaunchTimes;

//评分
+ (void)markRated: (BOOL)rated;
+ (BOOL)hasRated;

//本地默认端口
+ (uint16_t)preferedPort;

/**
 * 设置本地默认端口
 * <= 0 默认
 */
+ (void)savePreferedPort: (uint16_t)port;

/**
 * 允许设备
 */
+ (void)saveAllowedDeviceList: (NSArray *)list;
+ (NSArray *)getAllowedDeviceList;

+ (void)saveDisallowedDeviceList: (NSArray *)list;
+ (NSArray *)getDisallowedDeviceList;
//拒绝其他非允许设备
+ (void)setDisallowOtherDevice: (BOOL)value;
+ (BOOL)disallowOtherDevice;


@end
