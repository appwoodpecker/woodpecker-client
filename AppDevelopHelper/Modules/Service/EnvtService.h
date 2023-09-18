//
//  EnvtService.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/19.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kEnvtServiceWorkEnvtSetupFinish;
extern NSString * const kEnvtServiceWorkEnvtSetupUserInfoPlugin;

@interface EnvtService : NSObject

+ (EnvtService *)sharedService;

- (void)setupWorkEnvt;

//Appfile
- (NSString *)appFileWorkPath;
- (void)resetAppfileWorkPathIfNeeded;

//AppBundle
- (NSString *)appBundleWorkPath;
- (void)resetAppBundleWorkPathIfNeeded;

- (NSString *)pluginPath;

//Network
- (NSString *)networkWorkPath;

//Logger
- (NSString *)loggerWorkPath;

//iCloud
- (NSString *)iCloudWorkPath;
- (void)resetiCloudWorkPathIfNeeded;

//State Master
- (NSString *)stateMasterPath;

//config.plist配置
- (id)configWithKey: (NSString *)configKey;



@end
