//
//  Preference.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/1/5.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "Preference.h"
#import "ADHUserDefaultUtil.h"

static NSString * kPreferenceToolItem = @"kPreferenceToolItem";

static NSString * kPreferenceWelcomePageShowed = @"kPreferenceWelcomePageShowed";
static NSString * kPreferenceLatestVersion = @"kPreferenceLatestVersion";
static NSString * kPreferenceBetaDate = @"kPreferenceBetaDate";
static NSString * kPreferencePort = @"kPreferencePort";
static NSString * kPreferenceAllowedDevice = @"kPreferenceAllowedDevice";
static NSString * kPreferenceDisallowedDevice = @"kPreferenceDisallowedDevice";
static NSString * kPreferenceDisallowOtherDevice = @"kPreferenceDisallowOtherDevice";

@implementation Preference

+ (void)saveToolItem: (NSArray *)toolIdentifiers
{
    [ADHUserDefaultUtil setDefaultValue:toolIdentifiers forKey:kPreferenceToolItem];
}

+ (NSArray *)toolIdentifiers
{
    return [ADHUserDefaultUtil defaultValueForKey:kPreferenceToolItem];
}

+ (void)clearTools
{
    [Preference saveToolItem:@[]];
}

+ (BOOL)welcomePageShowed
{
    BOOL showed = [[ADHUserDefaultUtil defaultValueForKey:kPreferenceWelcomePageShowed] boolValue];
    return showed;
}

+ (void)setWelcomePageShowd: (BOOL)showed
{
    NSNumber * value = showed ? @1 : @0;
    [ADHUserDefaultUtil setDefaultValue:value forKey:kPreferenceWelcomePageShowed];
}

+ (void)setLatestVersion: (NSString *)version {
    [ADHUserDefaultUtil setDefaultValue:version forKey:kPreferenceLatestVersion];
}

+ (NSString *)latestVersion {
    NSString *version = [ADHUserDefaultUtil defaultValueForKey:kPreferenceLatestVersion];
    return adhvf_safestringfy(version);
}

//BETA
+ (NSDate *)betaStartDate {
    NSDate *resultDate = nil;
    NSDate *date = [ADHUserDefaultUtil versionDefaultValueForKey:kPreferenceBetaDate];
    if(date && [date isKindOfClass:[NSDate class]]) {
        resultDate = date;
    }
    return resultDate;
}

+ (void)setBetaStartDate: (NSDate *)date {
    [ADHUserDefaultUtil setVersionDefaultValue:date forKey:kPreferenceBetaDate];
}

//beta版本有效时间，30天
+ (NSTimeInterval)betaLifeInterval {
    return 30 * 24*60*60;
}


+ (void)addLaunchTimes {
    NSInteger launchTimes = [Preference getLaunchTimes];
    launchTimes ++;
    NSNumber *value = [NSNumber numberWithInteger:launchTimes];
    [ADHUserDefaultUtil setDefaultValue:value forKey:@"launchtimes"];
}

+ (void)resetLaunchTimes {
    NSNumber *value = [NSNumber numberWithInteger:0];
    [ADHUserDefaultUtil setDefaultValue:value forKey:@"launchtimes"];
}

+ (NSInteger)getLaunchTimes {
    NSNumber *value = [ADHUserDefaultUtil defaultValueForKey:@"launchtimes"];
    return [value integerValue];
}

+ (void)markRated: (BOOL)rated {
    NSNumber *value = [NSNumber numberWithBool:rated];
    [ADHUserDefaultUtil setDefaultValue:value forKey:@"rate"];
}

+ (BOOL)hasRated {
    NSNumber *value = [ADHUserDefaultUtil defaultValueForKey:@"rate"];
    return [value boolValue];
}

+ (void)setDefaultValue: (id)value forKey: (NSString *)key inDomain: (NSString *)domain {
    [ADHUserDefaultUtil setDefaultValue:value forKey:key inDomain:domain];
}

+ (id)defaultValueForKey: (NSString *)key inDomain: (NSString *)domain {
    return [ADHUserDefaultUtil defaultValueForKey:key inDomain:domain];
}

//port
+ (uint16_t)preferedPort {
    uint16_t port = [[ADHUserDefaultUtil defaultValueForKey:kPreferencePort] intValue];
    return port;
}

/**
 * 设置本地默认端口
 * <= 0 默认
 */
+ (void)savePreferedPort: (uint16_t)port {
    [ADHUserDefaultUtil setDefaultValue:[NSNumber numberWithInt:port] forKey:kPreferencePort];
}

/**
 * 允许设备
 */
+ (void)saveAllowedDeviceList: (NSArray *)list {
    [ADHUserDefaultUtil setDefaultValue:list forKey:kPreferenceAllowedDevice];
}

+ (NSArray *)getAllowedDeviceList {
    NSArray *list = [ADHUserDefaultUtil defaultValueForKey:kPreferenceAllowedDevice];
    if(!list) {
        list = @[];
    }
    return list;
}

+ (void)saveDisallowedDeviceList: (NSArray *)list {
    [ADHUserDefaultUtil setDefaultValue:list forKey:kPreferenceDisallowedDevice];
}

+ (NSArray *)getDisallowedDeviceList {
    NSArray *list = [ADHUserDefaultUtil defaultValueForKey:kPreferenceDisallowedDevice];
    if(!list) {
        list = @[];
    }
    return list;
}

//拒绝其他非允许设备
+ (void)setDisallowOtherDevice: (BOOL)value {
    [ADHUserDefaultUtil setDefaultValue:[NSNumber numberWithBool:value] forKey:kPreferenceDisallowOtherDevice];
}

+ (BOOL)disallowOtherDevice {
    BOOL value = [[ADHUserDefaultUtil defaultValueForKey:kPreferenceDisallowOtherDevice] boolValue];
    return value;
}

@end





