//
//  ADHPreferenceService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHPreferenceService.h"

static NSString * const ADHPreferenceServiceManualList          = @"ADHManualList";
static NSString * const ADHPreferenceServiceAutoConnectEnable   = @"ADHAutoConnectEnable";
static NSString * const ADHPreferenceServiceManualHost          = @"ADHAutoManualHost";
static NSString * const ADHPreferenceServiceManualPort          = @"ADHAutoManualPort";
static NSString * const ADHPreferenceServiceName                = @"ADHPreferedServiceName";


@implementation ADHPreferenceService

+ (ADHPreferenceService *)service
{
    static ADHPreferenceService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ADHPreferenceService alloc] init];
    });
    return service;
}

//manual servicelist
- (NSArray *)manualServiceList
{
    NSArray * list = nil;
    NSString * content = [ADHUserDefaultUtil defaultValueForKey:ADHPreferenceServiceManualList];
    if(content.length > 0){
        list = [content adh_jsonObject];
    }
    return list;
}

- (void)saveManulService: (NSArray *)dataList
{
    NSString * content = [dataList adh_jsonPresentation];
    [ADHUserDefaultUtil setDefaultValue:content forKey:ADHPreferenceServiceManualList];
}

//auto enabled
- (BOOL)autoConnectEnabled
{
    BOOL enabled = YES;
    NSNumber * value = [ADHUserDefaultUtil defaultValueForKey:ADHPreferenceServiceAutoConnectEnable];
    if(value){
        enabled = [value boolValue];
    }
    return enabled;
}

- (void)setAutoConnectedEnabled: (BOOL)enabled
{
    NSNumber * value = [NSNumber numberWithBool:enabled];
    [ADHUserDefaultUtil setDefaultValue:value forKey:ADHPreferenceServiceAutoConnectEnable];
}

- (BOOL)isLastManualConnect
{
    NSString * host = [self getLastManulServiceHost];
    uint16_t port = [self getLastManulServicePort];
    return (host.length > 0 && port > 0);
}

- (void)setLastManualService: (NSString *)host port: (uint16_t)port
{
    [ADHUserDefaultUtil setDefaultValue:adhvf_safestringfy(host) forKey:ADHPreferenceServiceManualHost];
    NSNumber * portValue = [NSNumber numberWithInt:port];
    [ADHUserDefaultUtil setDefaultValue:portValue forKey:ADHPreferenceServiceManualPort];
}

- (NSString *)getLastManulServiceHost
{
    NSString * host = [ADHUserDefaultUtil defaultValueForKey:ADHPreferenceServiceManualHost];
    return host;
}

- (uint16_t)getLastManulServicePort
{
    NSNumber * portValue = [ADHUserDefaultUtil defaultValueForKey:ADHPreferenceServiceManualPort];
    return (uint16_t)[portValue intValue];
}

- (void)clearLastManulService
{
    [self setLastManualService:adhvf_const_emptystr() port:0];
}

//用户上次连接serviceName
- (void)setLastServiceName: (NSString *)serviceName {
    [ADHUserDefaultUtil setDefaultValue:adhvf_safestringfy(serviceName) forKey:ADHPreferenceServiceName];
}

- (void)clearLastServiceName {
    [ADHUserDefaultUtil setDefaultValue:adhvf_const_emptystr() forKey:ADHPreferenceServiceName];
}

- (NSString *)getLastServiceName {
    NSString *name = [ADHUserDefaultUtil defaultValueForKey:ADHPreferenceServiceName];
    return adhvf_safestringfy(name);
}


@end















