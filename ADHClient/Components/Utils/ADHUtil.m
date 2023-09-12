//
//  ADHUtil.m
//  ADHClient
//
//  Created by 张小刚 on 2020/7/5.
//  Copyright © 2020 lifebetter. All rights reserved.
//

#import "ADHUtil.h"
#import <sys/utsname.h>
#import <netinet/in.h>
#import <netinet/tcp.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import<SystemConfiguration/CaptiveNetwork.h>

#if TARGET_OS_IPHONE

#elif TARGET_OS_MAC

@import AppKit;
@import SystemConfiguration;
@import Darwin;

#endif


@implementation ADHUtil

+ (NSString *)getDeviceModel {
   struct utsname systemInfo;
   uname(&systemInfo);
   NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return deviceModel;
}

+ (NSString *)localUSBIP {
    NSArray * addresses = [ADHUtil getIPAddresses];
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


// Get the local en0 ip(ipv4)
+ (NSString *)getLocalIPAddress {
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

//获取SSID --wifi名称
+ (NSString *)getSSID {
    NSString *ssid = nil;
#if TARGET_OS_IPHONE
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
        }
    }
#elif TARGET_OS_MAC
    
#endif
    return ssid;
}

#if TARGET_OS_IPHONE

+ (BOOL)isSimulator {
    if (TARGET_IPHONE_SIMULATOR == 1) {
        return YES;
    } else{
        return NO;
    }
}

#elif TARGET_OS_MAC

+ (BOOL)isSandboxed {
    NSString * homePath = NSHomeDirectory();
    NSDictionary *infoData = [[NSBundle mainBundle] infoDictionary];
    NSString * bundleId = infoData[@"CFBundleIdentifier"];
    return [homePath containsString:bundleId];
}

+ (NSString *)deviceName {
    NSString *computerName = (NSString *)CFBridgingRelease(SCDynamicStoreCopyComputerName(NULL, NULL));
    return computerName;
}

#endif

@end
