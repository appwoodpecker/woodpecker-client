//
//  DeviceUtil.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/2/6.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "DeviceUtil.h"
@import AppKit;
@import SystemConfiguration;
@import Darwin;

@implementation DeviceUtil

+ (NSString *)deviceName
{
    NSString *computerName = (NSString *)CFBridgingRelease(SCDynamicStoreCopyComputerName(NULL, NULL));
    return computerName;
}

+ (NSString *)hostName {
    //Users/zhangxiaogang/Library/Containers/lifebetter.woodpecker/Data
    NSString *userName = nil;
    NSString *homePath = NSHomeDirectory();
    if ([homePath hasPrefix:@"/Users/"]) {
        NSArray *components = [homePath componentsSeparatedByString:@"/"];
        if(components.count > 3) {
            userName = components[2];
        }
    }
    return userName;
}

//mac端使用
+ (NSString *)localIP {
    NSArray * addresses = [DeviceUtil getIPAddresses];
    NSString * localHost = nil;
    for (NSString *anAddress in addresses) {
        if (![anAddress hasPrefix:@"127"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            localHost = anAddress;
            break;
        }
    }
    return adhvf_safestringfy(localHost);
}

+ (NSString *)localUSBIP {
    NSArray * addresses = [DeviceUtil getIPAddresses];
    NSLog(@"%@",addresses);
    NSString * localHost = nil;
    for (NSString *anAddress in addresses) {
        if ([anAddress hasPrefix:@"169.254"] && [[anAddress componentsSeparatedByString:@"."] count] == 4) {
            localHost = anAddress;
            break;
        }
    }
    return adhvf_safestringfy(localHost);
}

+ (NSArray *)getIPAddresses
{
    NSMutableArray * addresses = [NSMutableArray array];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0){
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL){
            if(temp_addr->ifa_addr->sa_family == AF_INET){
                // Get NSString from C String
                NSString * address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                if(address.length > 0){
                    [addresses addObject:address];
                }
            }else if(temp_addr->ifa_addr->sa_family == AF_INET6){
                //IPv6
                
                /*
                char tmp[50];
                struct sockaddr_in6 * in6 = (struct sockaddr_in6*) temp_addr->ifa_addr;
                inet_ntop(AF_INET6, &in6->sin6_addr, tmp, sizeof(tmp));
                NSString * address = [NSString stringWithUTF8String:tmp];
                if(address.length > 0){
                    [addresses addObject:address];
                }
                 */
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return addresses;
}

+ (void)pasteText:(NSString *)text
{
    if(text.length == 0) return;
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text forType:NSPasteboardTypeString];
}

+ (BOOL)isCN {
    NSLocale * locale = [NSLocale currentLocale];
    //国家码 -> 手机国家地区
    NSString *countryId = [locale objectForKey:NSLocaleCountryCode];
    return ([countryId rangeOfString:@"CN" options:NSCaseInsensitiveSearch].location != NSNotFound);
}

+ (NSString *)appVersion {
    NSDictionary *infoData = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    return version;
}

+ (BOOL)isOptionPressed {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    NSEventModifierFlags flags = [event modifierFlags];
    //option是否摁下
    NSUInteger value = (flags & NSEventModifierFlagOption);
    return (value > 0);
}

+ (BOOL)isCmdPressed {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    NSEventModifierFlags flags = [event modifierFlags];
    //command是否摁下
    NSUInteger value = (flags & NSEventModifierFlagCommand);
    return (value > 0);
}

+ (BOOL)isSandboxed {
    NSString * homePath = NSHomeDirectory();
    NSDictionary *infoData = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = infoData[@"CFBundleIdentifier"];
    return [homePath containsString:bundleId];
}

+ (BOOL)isDarkMode {
    BOOL ret = NO;
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleInterfaceStyle"];
    if([value isKindOfClass:[NSString class]] && [value isEqualToString:@"Dark"]) {
        ret = YES;
    }
    return ret;
}

+ (NSString *)getDeviceModel: (NSString *)deviceModel {
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceModel;
}

+ (NSString *)getDownloadPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
    NSString * path = paths[0];
    return path;
}

@end





