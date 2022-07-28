//
//  EnvtService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/19.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "EnvtService.h"
#import "ADHUserDefaultUtil.h"

NSString * const kEnvtServiceWorkEnvtSetupFinish = @"kEnvtServiceWorkEnvtSetupFinish";
NSString * const kEnvtServiceWorkEnvtSetupUserInfoPlugin = @"pluginUpdate";
NSString * const kUDPluginDomain = @"plugin";
NSString * const kUDPluginVersionKey = @"version";


@interface EnvtService ()

@property (nonatomic, strong) NSDictionary *configData;

@end

@implementation EnvtService

+ (EnvtService *)service
{
    static EnvtService * service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[EnvtService alloc] init];
    });
    return service;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
        self.configData = data;
    });
}

- (void)setupWorkEnvt {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //沙盒目录
        NSString * sandBoxPath = [self appFileWorkPath];
        if(![ADHFileUtil dirExistsAtPath:sandBoxPath]){
            [ADHFileUtil createDirAtPath:sandBoxPath];
        }
        //插件目录
        NSString * pluginPath = [self pluginPath];
        if(![ADHFileUtil dirExistsAtPath:pluginPath]){
            [ADHFileUtil createDirAtPath:pluginPath];
        }
        //安装(更新)插件
        NSArray * pluginList = [self loadPluginList];
        NSDictionary * localVersions = [self loadPluginVersions];
        BOOL pluginUpdated = NO;
        for (NSDictionary * data in pluginList) {
            NSString * pluginName = data[@"name"];
            NSInteger newVersion = [data[@"version"] integerValue];
            NSInteger localVersion = [localVersions[pluginName] integerValue];
            NSString * pluginItemPath = [self getPluginItemPath:pluginName];
            BOOL needUpdate = NO;
            if(newVersion > localVersion){
                needUpdate = YES;
            }
#if DEBUG
            needUpdate = YES;
#endif
            if(needUpdate){
                if([ADHFileUtil dirExistsAtPath:pluginItemPath]){
                    [ADHFileUtil deleteFileAtPath:pluginItemPath];
                }
                NSString * resPath = [[NSBundle mainBundle] pathForResource:pluginName ofType:@"bundle"];
                NSFileManager * fileManager = [NSFileManager defaultManager];
                NSError * error = nil;
                [fileManager copyItemAtPath:resPath toPath:pluginItemPath error:&error];
                NSDate * createDate = [NSDate date];
                [fileManager setAttributes:@{
                                             NSFileCreationDate:createDate,
                                             } ofItemAtPath:pluginItemPath error:nil];
                [self updatePluginVersion:pluginName version:newVersion];
                pluginUpdated = YES;
            }
        }
        //Network
        NSString * networkPath = [self networkWorkPath];
        if(![ADHFileUtil dirExistsAtPath:networkPath]){
            [ADHFileUtil createDirAtPath:networkPath];
        }
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        if(pluginUpdated){
            userInfo[kEnvtServiceWorkEnvtSetupUserInfoPlugin] = adhvf_const_strtrue();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kEnvtServiceWorkEnvtSetupFinish object:self userInfo:userInfo];
        });
    });
}

- (void)resetAppfileWorkPathIfNeeded {
    //沙盒目录
    NSString * sandboxPath = [self appFileWorkPath];
    if(![ADHFileUtil dirExistsAtPath:sandboxPath]){
        [ADHFileUtil createDirAtPath:sandboxPath];
    }
}

- (void)resetAppBundleWorkPathIfNeeded {
    //Bundle工作目录
    NSString * workPath = [self appBundleWorkPath];
    if(![ADHFileUtil dirExistsAtPath:workPath]){
        [ADHFileUtil createDirAtPath:workPath];
    }
}

- (NSArray *)loadPluginList {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"plugin-config" ofType:@"plist"];
    NSDictionary * data = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray * list = data[@"list"];
    return list;
}

- (NSDictionary *)loadPluginVersions
{
    NSDictionary * versionData = [ADHUserDefaultUtil defaultValueForKey:kUDPluginVersionKey inDomain:kUDPluginDomain];
    if(![versionData isKindOfClass:[NSDictionary class]]){
        versionData = @{};
    }
    return versionData;
}

- (void)updatePluginVersion: (NSString *)pluginName version: (NSInteger)version
{
    NSDictionary * versionData = [self loadPluginVersions];
    NSMutableDictionary * data = [versionData mutableCopy];
    data[pluginName] = adhvf_string_integer(version);
    [ADHUserDefaultUtil setDefaultValue:data forKey:kUDPluginVersionKey inDomain:kUDPluginDomain];
}

//Logger
- (NSString *)loggerWorkPath
{
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"Logger"];
}

//Network
- (NSString *)networkWorkPath
{
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"Network"];
}

//AppFile
- (NSString *)appFileWorkPath
{
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"Sandbox"];
}

//App Bundle
- (NSString *)appBundleWorkPath {
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"AppBundle"];
}

- (NSString *)applicationWorkPath
{
    return [[self basePath] stringByAppendingPathComponent:@"Applications"];
}

//iCloud
- (NSString *)iCloudWorkPath {
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"iCloud"];
}

//rest iCloud
- (void)resetiCloudWorkPathIfNeeded {
    NSString * workPath = [self iCloudWorkPath];
    if(![ADHFileUtil dirExistsAtPath:workPath]){
        [ADHFileUtil createDirAtPath:workPath];
    }
}

//State Master
- (NSString *)stateMasterPath {
    return [[self applicationWorkPath] stringByAppendingPathComponent:@"StateMaster"];
}

//Plugin
- (NSString *)pluginPath
{
    return [[self basePath] stringByAppendingPathComponent:@"Plugins"];
}

//Plugin item path
- (NSString *)getPluginItemPath: (NSString *)pluginName
{
    if(![pluginName hasSuffix:@"bundle"]){
        pluginName = [NSString stringWithFormat:@"%@.bundle",pluginName];
    }
    NSString * path = [[self pluginPath] stringByAppendingPathComponent:pluginName];
    return path;
}

- (NSArray *)defaultPlugins
{
    return @[
             @"Web Console",
             ];
}

- (NSString *)basePath
{
    NSString * homePath = NSHomeDirectory();
    NSString * docPath = [homePath stringByAppendingPathComponent:@"Documents"];
    NSString * basePath = [docPath stringByAppendingPathComponent:[self appName]];
    return basePath;
}

//okay always WoodPecker
- (NSString *)appName
{
    return @"WoodPecker";
}


#pragma mark -----------------   Config   ----------------

//config.plist配置
- (id)configWithKey: (NSString *)configKey {
    id result = nil;
    if(configKey.length > 0) {
        result = self.configData[configKey];
    }
    return result;
}

@end












