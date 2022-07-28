//
//  MacDefaultActionService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "MacDefaultActionService.h"
#import "EnvtService.h"

@interface MacDefaultActionService ()

@property (nonatomic, strong) NSDictionary * configData;

@end

@implementation MacDefaultActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.default";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"echo" : NSStringFromSelector(@selector(onRequestDefault:)),
             @"p" : NSStringFromSelector(@selector(onRequestPing:)),
             };
}

/**
 读取文件
 */
- (void)onRequestDefault: (ADHRequest *)request
{
    NSDictionary * requestBody = request.body;
    if(!requestBody){
        requestBody = @{};
    }
    NSMutableDictionary * body = [requestBody mutableCopy];
    body[@"client"] = @"Hi, I`m Mac";
    [request finishWithBody:body payload:request.payload];
}

/**
 * 心跳
 */
- (void)onRequestPing: (ADHRequest *)request {
    [request finishWithBody:nil payload:nil];
}

@end










