//
//  ADHService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/4.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHService.h"
#import "ADHLogUtil.h"

@implementation ADHAction

+ (ADHAction *)actionWithService: (NSString *)service name: (NSString *)name handler: (NSString *)handler
{
    ADHAction * api = [[ADHAction alloc] init];
    api.service = service;
    api.name = name;
    api.handler = handler;
    return api;
}

@end

@implementation ADHService

- (void)onServiceInit
{
    adhConsoleLog(@"service \"%@\" created",[[self class] serviceName]);
}

//filebrowser
+ (NSString *)serviceName
{
    return @"default";
}

/** support two formats:
 1. filesystem - @selector(onRequestFileSystem:)
 2. filesystem - @selector(onRequestFileSystem:context:)
 */
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{};
}

+ (BOOL)isShared
{
    return YES;
}

@end












