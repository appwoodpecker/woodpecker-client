//
//  ADHPreferenceService.h
//  ADHClient
//
//  Created by 张小刚 on 2017/11/18.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADHPreferenceService : NSObject

+ (ADHPreferenceService *)service;

//用户设置地址
- (NSArray *)manualServiceList;
- (void)saveManulService: (NSArray *)dataList;
//是否自动链接
- (BOOL)autoConnectEnabled;
- (void)setAutoConnectedEnabled: (BOOL)enabled;

//手动连接信息
- (BOOL)isLastManualConnect;
- (void)setLastManualService: (NSString *)host port: (uint16_t)port;
- (NSString *)getLastManulServiceHost;
- (uint16_t)getLastManulServicePort;
- (void)clearLastManulService;

//用户上次连接serviceName
- (void)setLastServiceName: (NSString *)serviceName;
- (NSString *)getLastServiceName;
- (void)clearLastServiceName;


@end
