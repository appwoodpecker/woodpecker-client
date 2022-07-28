//
//  FileBrowserActionService.m
//  WoodPecker
//
//  Created by 张小刚 on 2018/7/11.
//  Copyright © 2018 lifebetter. All rights reserved.
//

#import "FileBrowserActionService.h"

NSString * const kFileBrowserActionServiceFileUpdateNotification = @"kFileBrowserActionServiceFileUpdateNotification";

@implementation FileBrowserActionService

//filebrowser
+ (NSString *)serviceName
{
    return @"adh.filebrowser";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"fileUpdate" : NSStringFromSelector(@selector(onRequestFileUpdate:context:)),
             };
}

- (void)onRequestFileUpdate: (ADHRequest *)request context:(ADHApiClient *)apiClient {
    NSDictionary *body = request.body;
    [request finish];
    if(!body) {
        body = @{};
    }
    NSMutableDictionary *userInfo = [body mutableCopy];
    AppContext *context = [AppContextManager.manager contextWithApiClient:apiClient];
    if(context) {
        userInfo[@"context"] = context;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFileBrowserActionServiceFileUpdateNotification object:self userInfo:userInfo];
}

@end
