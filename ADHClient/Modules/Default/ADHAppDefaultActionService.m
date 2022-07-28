//
//  AppDefaultActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHAppDefaultActionService.h"

@implementation ADHAppDefaultActionService

+ (BOOL)isShared {
    return YES;
}

//filebrowser
+ (NSString *)serviceName {
    return @"adh.default";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"echo" : NSStringFromSelector(@selector(onRequestDefault:)),
             };
}

/**
 读取文件
 */
- (void)onRequestDefault: (ADHRequest *)request {
#if TARGET_OS_IPHONE
    NSDictionary * requestBody = request.body;
    if(!requestBody){
        requestBody = @{};
    }
    NSBundle *bundle = [[ADHOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    NSMutableDictionary * body = [requestBody mutableCopy];
    body[@"client"] = @"Hi, I`m App :)";
    body[@"message"] = @"If you received this message, it means your app could not reponse to the action correctly.";
    body[@"success"] = @(0);
    body[@"version"] = adhvf_safestringfy(version);
    [request finishWithBody:body payload:request.payload];
#elif TARGET_OS_MAC
    NSDictionary * requestBody = request.body;
    if(!requestBody){
        requestBody = @{};
    }
    NSBundle *bundle = [[ADHMacClientOrganizer sharedOrganizer] adhBundle];
    NSDictionary * infoData = [bundle infoDictionary];
    NSString *version = infoData[@"CFBundleShortVersionString"];
    NSMutableDictionary * body = [requestBody mutableCopy];
    body[@"client"] = @"Hi, I`m App :)";
    body[@"message"] = @"If you received this message, it means your app could not reponse to the action correctly.";
    body[@"success"] = @(0);
    body[@"version"] = adhvf_safestringfy(version);
    [request finishWithBody:body payload:request.payload];
#endif
}


@end
