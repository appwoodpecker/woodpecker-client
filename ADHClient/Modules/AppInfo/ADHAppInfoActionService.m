//
//  AppInfoActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHAppInfoActionService.h"
#import "ADHUtil.h"
#if TARGET_OS_IPHONE
#include <mach/mach_host.h>
#import "ADHFirebaseActionService.h"
#elif TARGET_OS_MAC

#endif

@implementation ADHAppInfoActionService

+ (NSString *)serviceName
{
    return @"adh.appinfo";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             //刚连接后获取基本信息
             @"appinfo" : NSStringFromSelector(@selector(onRequestAppInfo:)),
             //更多额外信息
             @"info" : NSStringFromSelector(@selector(onRequestInfo:)),
             @"closeapp" : NSStringFromSelector(@selector(onRequestCloseApp:)),
             @"entitlement" : NSStringFromSelector(@selector(onRequestEntitlement:)),
             ///dashboard
             @"dashboard" : NSStringFromSelector(@selector(onRequestDashboard:)),
             //基本信息
             @"basicInfo" : NSStringFromSelector(@selector(onRequestBasicInfo:)),
             };
}

/**
 * app链接后，获取基本信息
 */
- (void)onRequestAppInfo: (ADHRequest *)request {
#if TARGET_OS_IPHONE
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceName = [device name];
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = info[@"CFBundleIdentifier"];
    //CFBundleDisplayName or CFBundleName
    NSString * appName = info[@"CFBundleDisplayName"];
    if(appName.length == 0){
        appName = info[@"CFBundleName"];
    }
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"deviceName"] = adhvf_safestringfy(deviceName);
    data[@"bundleId"] = adhvf_safestringfy(bundleId);
    data[@"appName"] = adhvf_safestringfy(appName);
    data[@"systemVersion"] = adhvf_safestringfy(systemVersion);
    data[@"frameworkVersion"] = adhvf_safestringfy([self getFrameworkVersion]);
    if([self isSimulator]) {
        data[@"simulator"] = @(1);
        //simulator info
        NSDictionary *environment = [[NSProcessInfo processInfo] environment];
        NSString *userName = [environment objectForKey:@"USER"];
        if (!userName) {
            NSString *simulatorHostHome = [environment objectForKey:@"SIMULATOR_HOST_HOME"];
            if ([simulatorHostHome hasPrefix:@"/Users/"]) {
                userName = [simulatorHostHome substringFromIndex:7];
            }
        }
        if(userName) {
            data[@"simhost"] = userName;
        }
    }
    NSMutableArray *appList = [NSMutableArray array];
    //firebase
    if([ADHFirebaseActionService available]) {
        [appList addObject:@"firebase"];
    }
    data[@"apptoollist"] = appList;
    [request finishWithBody:data];
#elif TARGET_OS_MAC
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString * deviceName = [ADHUtil deviceName];
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = info[@"CFBundleIdentifier"];
    //CFBundleDisplayName or CFBundleName
    NSString * appName = info[@"CFBundleDisplayName"];
    if(appName.length == 0){
        appName = info[@"CFBundleName"];
    }
    NSString *systemVersion = [processInfo operatingSystemVersionString];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"deviceName"] = adhvf_safestringfy(deviceName);
    data[@"bundleId"] = adhvf_safestringfy(bundleId);
    data[@"appName"] = adhvf_safestringfy(appName);
    data[@"systemVersion"] = adhvf_safestringfy(systemVersion);
    data[@"frameworkVersion"] = adhvf_safestringfy([self getFrameworkVersion]);
    data[@"platform"] = [NSNumber numberWithInt:ADHPlatformMacOS];
    data[@"sandbox"] = [NSNumber numberWithBool:[ADHUtil isSandboxed]];
    [request finishWithBody:data];
#endif
}

#if TARGET_OS_IPHONE
- (BOOL)isSimulator {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    BOOL result = NO;
    if(hostInfo.cpu_type == CPU_TYPE_X86 || hostInfo.cpu_type == CPU_TYPE_X86_64) {
        result = YES;
    }
    return result;
}
#endif

- (void)onRequestCloseApp: (ADHRequest *)request {
#if TARGET_OS_IPHONE
    [[ADHOrganizer sharedOrganizer] clearAutoConnectTry];
    [request finish];
#elif TARGET_OS_MAC
    [[ADHMacClientOrganizer sharedOrganizer] clearAutoConnectTry];
    [request finish];
#endif
}

- (void)onRequestEntitlement: (ADHRequest *)request {
#if TARGET_OS_IPHONE
    NSString *path = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [request finishWithBody:@{} payload:data];
#elif TARGET_OS_MAC
    [request finish];
#endif
}

- (void)onRequestInfo : (ADHRequest *)request {
#if TARGET_OS_IPHONE
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableDictionary *fontData = [NSMutableDictionary dictionary];
    //system default
    //@升级维护
    NSArray *defaultFontNames = @[
                                  @".SFUIText-Light",
                                  @".SFUIText",
                                  @".SFUIText-Medium",
                                  @".SFUIText-Semibold",
                                  @".SFUIText-Bold",
                                  @".SFUIText-Heavy"
                                  ];
    fontData[@"System"] = defaultFontNames;
    //system fonts
    NSMutableDictionary *fonts = [NSMutableDictionary dictionary];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *familyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        if([fontNames isKindOfClass:[NSArray class]]) {
            fonts[familyName] = fontNames;
        }
    }
    fontData[@"fonts"] = fonts;
    data[@"font"] = fontData;
    [request finishWithBody:data];
#elif TARGET_OS_MAC
    [request finish];
#endif
}



#pragma mark -----------------   Dashboard   ----------------

- (void)onRequestDashboard : (ADHRequest *)request {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSData *payload = nil;
#if TARGET_OS_IPHONE
    //CFBundleDisplayName or CFBundleName
    NSDictionary * info = [[NSBundle mainBundle] infoDictionary];
    NSString * appName = info[@"CFBundleDisplayName"];
    if(appName.length == 0){
        appName = info[@"CFBundleName"];
    }
    NSString * bundleId = info[@"CFBundleIdentifier"];
    NSString * version = info[@"CFBundleShortVersionString"];
    NSString * build = info[@"CFBundleVersion"];
    UIDevice * device = [UIDevice currentDevice];
    NSString * deviceName = [device name];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    UIImage *iconImage = [UIImage imageNamed:@"AppIcon60x60"];
    if(iconImage) {
        NSData *iconData = UIImagePNGRepresentation(iconImage);
        payload = iconData;
    }
    data[@"appName"] = adhvf_safestringfy(appName);
    data[@"bundleId"] = adhvf_safestringfy(bundleId);
    data[@"version"] = adhvf_safestringfy(version);
    data[@"build"] = adhvf_safestringfy(build);
    data[@"systemVersion"] = adhvf_safestringfy(systemVersion);
    data[@"deviceName"] = adhvf_safestringfy(deviceName);
#endif
    [request finishWithBody:data payload:payload];
}

- (void)onRequestBasicInfo : (ADHRequest *)request {
    /*
     Device:
     
     name;
     model;
     systemName;
     systemVersion;
     orientation
     */
    NSMutableArray * list = [NSMutableArray array];
#if TARGET_OS_IPHONE
    UIDevice * device = [UIDevice currentDevice];
    [list addObject:@{
                      @"name" : @"Device Name",
                      @"value" : adhvf_safestringfy([device name]),
                      }];
    [list addObject:@{
                      @"name" : @"Device Model",
                      @"value" : adhvf_safestringfy([ADHUtil getDeviceModel]),
                      }];
    NSString *sys = [NSString stringWithFormat:@"%@ %@",[device systemName],[device systemVersion]];
    [list addObject:@{
                      @"name": @"System Name",
                      @"value" : adhvf_safestringfy(sys),
                      }];
    /*
     Resolution
     Size(in points)
     Scale
     */
    UIScreen * screen = [UIScreen mainScreen];
    CGFloat screenWidth = screen.bounds.size.width;
    CGFloat screenHeight = screen.bounds.size.height;
    CGFloat scale = screen.scale;
    NSString *resolution = [NSString stringWithFormat:@"%.f x %.f (%.fx)",screenWidth,screenHeight,scale];
    NSString *resTip = [NSString stringWithFormat:@"%.f x %.f",screenWidth*scale,screenHeight*scale];
    [list addObject:@{
                      @"name": @"Resolution",
                      @"value" : resolution,
                      @"tip" : resTip,
                      }];
#endif
    /*
     语言,国家
     */
    NSLocale * locale = [NSLocale currentLocale];
    [list addObject:@{
                      @"name": @"Locale",
                      @"value" : adhvf_safestringfy([locale objectForKey:NSLocaleIdentifier]),
                      }];
    /*
     时区，日历
     */
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [list addObject:@{
                      @"name" : @"Timezone",
                      @"value" : adhvf_safestringfy([self readbleTimeZone:localTimeZone]),
                      }];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [list addObject:@{
                      @"name" : @"Calendar",
                      @"value" : adhvf_safestringfy([self readbleCalendar:calendar]),
                      }];
    //网络信息
#if TARGET_OS_IPHONE
    NSString *ssid = [ADHUtil getSSID];
    NSString *localIp = [ADHUtil getLocalIPAddress];
    NSString *network = nil;
    if(ssid.length > 0 || localIp.length > 0) {
        NSMutableArray *list = [NSMutableArray array];
        if(ssid.length > 0) {
            [list addObject:ssid];
        }
        if(localIp.length > 0) {
            [list addObject:localIp];
        }
        network = [list componentsJoinedByString:@" "];
    }
    [list addObject:@{
        @"name" : @"Network",
        @"value" : adhvf_safestringfy(network),
    }];
#endif
    /*
     App Info:
     font
     url scheme
     */
    NSDictionary * infoDic = [[NSBundle mainBundle] infoDictionary];
    [list addObject:@{
                      @"name" : @"Fonts",
                      @"value" : [self getAppFonts:infoDic],
                      }];
    [list addObject:@{
                      @"name" : @"URL Schemes",
                      @"value" : [self getUrlSchemes:infoDic],
                      }];
    NSDictionary * data = @{
                            @"name" : @"",
                            @"value" : list,
                            };
    [request finishWithBody:data];
}

//fonts
- (NSArray *)getAppFonts: (NSDictionary *)infoData {
    NSArray *fonts = infoData[@"UIAppFonts"];
    NSMutableArray *fontList = [NSMutableArray array];
    for (NSString *fontName in fonts) {
        NSDictionary *data = @{
            @"value" : fontName,
        };
        [fontList addObject:data];
    }
    return fontList;
}

//url schemes
- (NSArray *)getUrlSchemes: (NSDictionary *)infoData {
    NSArray *types = infoData[@"CFBundleURLTypes"];
    NSMutableArray * typeList = [NSMutableArray array];
    if(types && [types isKindOfClass:[NSArray class]]) {
        for (NSDictionary *typeData in types) {
            NSArray *items = typeData[@"CFBundleURLSchemes"];
            if(items && [items isKindOfClass:[NSArray class]]) {
                NSString *typeText = [items componentsJoinedByString:@","];
                if(typeText.length > 0) {
                    NSDictionary *data = @{
                        @"value" : typeText,
                    };
                    [typeList addObject:data];
                }
            }
        }
    }
    return typeList;
}

- (NSString *)readbleTimeZone: (NSTimeZone *)timezone {
    //name abbreviation，secondsFromGMT
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"%@ %@ %zd",timezone.name,timezone.abbreviation,timezone.secondsFromGMT];
    return text;
}

- (NSString *)readbleCalendar: (NSCalendar *)calendar {
    NSMutableString *text = [NSMutableString string];
    //calendarIdentifier
    [text appendFormat:@"%@",calendar.calendarIdentifier];
    return text;
}


- (NSString *)getFrameworkVersion {
    NSString *version = nil;
#if TARGET_OS_IPHONE
    NSBundle *bundle = [[ADHOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    version = infoData[@"CFBundleShortVersionString"];
#elif TARGET_OS_MAC
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    version = infoData[@"CFBundleShortVersionString"];
#endif
    return version;
}

@end
