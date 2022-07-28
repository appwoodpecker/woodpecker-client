//
//  ADHNetworkActionService.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/5.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHNetworkActionService.h"
#import "ADHNetworkObserver.h"
#import "ADHNetworkRecorder.h"
#import "ADHNetworkTransaction.h"
#import "ADHNetworkCookie.h"

@interface ADHNetworkActionService ()

@end

@implementation ADHNetworkActionService

+ (NSString *)serviceName
{
    return @"adh.network";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList
{
    return @{
             @"start" : NSStringFromSelector(@selector(onRequestNetworkStart:)),
             @"stop" : NSStringFromSelector(@selector(onRequestNetworkStop:)),
             @"requestResponseBody" : NSStringFromSelector(@selector(onRequestResponseBody:)),
             @"cookieList" : NSStringFromSelector(@selector(onRequestCookieList:)),
             };
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[ADHNetworkRecorder defaultRecorder] clearContext];
    }
    return self;
}

- (void)onRequestNetworkStart: (ADHRequest *)request
{
    [[ADHNetworkObserver sharedObserver] start];
    [request finish];
}

- (void)onRequestNetworkStop: (ADHRequest *)request
{
    [[ADHNetworkObserver sharedObserver] stop];
    [[ADHNetworkRecorder defaultRecorder] clearRecordedActivity];
    [request finish];
}

- (void)onRequestResponseBody: (ADHRequest *)request
{
    NSDictionary * data = request.body;
    NSString *  requestId = data[@"requestId"];
    NSData * responseBody = [[ADHNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:requestId];
    if(responseBody){
        NSDictionary * info = @{
                                @"success" : adhvf_const_strtrue(),
                                };
        [request finishWithBody:info payload:responseBody];
    }else{
        NSDictionary * info = @{
                                @"success" : adhvf_const_strfalse(),
                                };
        [request finishWithBody:info];
    }
}

- (void)onRequestCookieList: (ADHRequest *)request {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = storage.cookies;
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSHTTPCookie *cookie in cookies) {
        ADHNetworkCookie *nwCookie = [ADHNetworkCookie cookieWithHttpCookie:cookie];
        NSDictionary *data = [nwCookie dicPresentation];
        [dataList addObject:data];
    }
    NSString *content = [dataList adh_jsonPresentation];
    [request finishWithBody:@{
                              @"list" : adhvf_safestringfy(content),
                              }];
}


@end









