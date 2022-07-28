//
//  LogActionService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/26.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "LogActionService.h"
#import "LogRecorder.h"

@implementation LogActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.logger";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"log" : NSStringFromSelector(@selector(onRequestLog:context:)),
             @"console" : NSStringFromSelector(@selector(onReceiveConsoleLogRequest:context:)),
             };
}

- (void)onRequestLog: (ADHRequest *)request context:(ADHApiClient *)apiClient
{
    NSDictionary * data = request.body;
    NSData * payload = request.payload;
    AppContext *context = [AppContextManager.manager contextWithApiClient:apiClient];
    if(context) {
        LogRecorder *recorder = [LogRecorder recorderWithContext:context];
        [recorder logWithBody:data payload:payload];
    }
    [request finish];
}

- (void)onReceiveConsoleLogRequest: (ADHRequest *)request context:(ADHApiClient *)apiClient {
    NSDictionary *body = request.body;
    NSArray<NSString *> *list = body[@"list"];
    if([list isKindOfClass:[NSArray class]] && list.count > 0) {
        AppContext *context = [AppContextManager.manager contextWithApiClient:apiClient];
        if(context) {
            LogRecorder *recorder = [LogRecorder recorderWithContext:context];
            [recorder onReceiveNewLog:list];
        }
    }
    [request finish];
}

@end






















