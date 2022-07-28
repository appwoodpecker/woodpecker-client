//
//  ADHMetaService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/1/8.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "ADHMetaService.h"

#if TARGET_OS_IPHONE
#import "ADHOrganizerPrivate.h"
#elif TARGET_OS_MAC
#import "ADHMacClientOrganizerPrivate.h"
#endif

@implementation ADHMetaService

+ (NSString *)serviceName
{
    return @"adh.woodpecker";
}

+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"actionlist" : NSStringFromSelector(@selector(onRequestActionList:)),
             @"framework" : NSStringFromSelector(@selector(onRequestFrameworkVersion:)),
             };
}

- (void)onRequestActionList: (ADHRequest *)request {
    ADHDispatcher *dispatcher = nil;
#if TARGET_OS_IPHONE
    dispatcher = [[ADHOrganizer sharedOrganizer] dispatcher];
#elif TARGET_OS_MAC
    dispatcher = [[ADHMacClientOrganizer sharedOrganizer] dispatcher];
#endif
    NSArray * serviceList = [dispatcher registeredServiceList];
    NSArray * actionList = [dispatcher registeredActionList];
    NSMutableDictionary * data = [NSMutableDictionary dictionary];
    data[@"service"] = serviceList;
    data[@"action"] = actionList;
    [request finishWithBody:data];
}

- (void)onRequestFrameworkVersion: (ADHRequest *)request {
#if TARGET_OS_IPHONE
    NSBundle *bundle = [[ADHOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    [request finishWithBody:@{
                              @"version" : adhvf_safestringfy(version),
                              }];
#elif TARGET_OS_MAC
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    [request finishWithBody:@{
                              @"version" : adhvf_safestringfy(version),
                              }];
#endif
}


@end
