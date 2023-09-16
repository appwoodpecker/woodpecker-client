//
//  WebActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/26.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

#import "WebActionService.h"
NSString *const kWebActionServiceNewLog = @"WebActionServiceNewLog";
NSString *const kWebActionServiceWebViewUpdate = @"WebActionServiceWebViewUpdate";

@implementation WebActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.webservice";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"log" : NSStringFromSelector(@selector(onRequestLog:context:)),
             @"webviewUpdate" : NSStringFromSelector(@selector(onWebViewUpdateRequest:context:)),
             };
}

/**
 log
 */
- (void)onRequestLog: (ADHRequest *)request context:(ADHApiClient *)apiClient {
    NSDictionary *body = request.body;
    if(!body) {
        body = @{};
    }
    NSMutableDictionary *userInfo = [body mutableCopy];
    AppContext *context = [AppContextManager.sharedManager contextWithApiClient:apiClient];
    if(context) {
        userInfo[@"context"] = context;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebActionServiceNewLog object:self userInfo:userInfo];
    [request finish];
}

- (void)onWebViewUpdateRequest: (ADHRequest *)request context:(ADHApiClient *)apiClient {
    NSDictionary *body = request.body;
    if(!body) {
        body = @{};
    }
    NSMutableDictionary *userInfo = [body mutableCopy];
    AppContext *context = [AppContextManager.sharedManager contextWithApiClient:apiClient];
    if(context) {
        userInfo[@"context"] = context;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebActionServiceWebViewUpdate object:self userInfo:userInfo];
    [request finish];
}

@end
