//
//  UserDefaultUtil.m
//  ShiShangQuan
//
//  Created by 张 小刚 on 13-9-23.
//  Copyright (c) 2013年 duohuo. All rights reserved.
//

#import "ADHUserDefaultUtil.h"

static NSString * const UserDefaultUtilDefaultDomain = @"woodpecker";

@implementation ADHUserDefaultUtil

+ (void)setDefaultValue: (id)value forKey: (NSString *)key
{
    [self setDefaultValue:value forKey:key inDomain:UserDefaultUtilDefaultDomain];
}

+ (id)defaultValueForKey: (NSString *)key
{
    return [self defaultValueForKey:key inDomain:UserDefaultUtilDefaultDomain];
}

+ (void)empty
{
    [self emptyDomain:UserDefaultUtilDefaultDomain];
}

+ (void)setVersionDefaultValue: (id)value forKey: (NSString *)key
{
    [self setDefaultValue:value forKey:key inDomain:[self appVersion]];
}

+ (id)versionDefaultValueForKey: (NSString *)key
{
    return [self defaultValueForKey:key inDomain:[self appVersion]];
}

+ (void)emptyVersion
{
    [self emptyDomain:[self appVersion]];
}

+ (void)setDefaultValue: (id)value forKey: (NSString *)key inDomain: (NSString *)domain
{
    NSParameterAssert(value);
    NSParameterAssert(key);
    NSParameterAssert(![domain isEqualToString:@""]);
    if(!domain){
        domain = UserDefaultUtilDefaultDomain;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * setting = [userDefaults valueForKey:domain];
    if(setting == nil) setting = @{};
    NSMutableDictionary * mutableSetting = [NSMutableDictionary dictionaryWithDictionary:setting];
    mutableSetting[key] = value;
    [userDefaults setValue:mutableSetting forKey:domain];
    [userDefaults synchronize];
}

+ (id)defaultValueForKey: (NSString *)key inDomain: (NSString *)domain
{
    NSParameterAssert(key);
    NSParameterAssert(![domain isEqualToString:@""]);
    if(!domain){
        domain = UserDefaultUtilDefaultDomain;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * setting = [userDefaults valueForKey:domain];
    return setting[key];
}

+ (void)emptyDomain: (NSString *)domain
{
    NSParameterAssert(![domain isEqualToString:@""]);
    if(!domain){
        domain = UserDefaultUtilDefaultDomain;
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * empty = @{};
    [userDefaults setValue:empty forKey:domain];
    [userDefaults synchronize];
}

#pragma mark -----------------   Util   ----------------

+ (NSString *)appVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return version;
}

@end


































