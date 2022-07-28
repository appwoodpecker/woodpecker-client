//
//  ADHWebDebugActionService.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/17.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

@import UIKit;
@import WebKit;
#import "ADHWebDebugActionService.h"
#import "ADHViewDebugService.h"

typedef void (^ADHWebDebugCompletion)(NSString * result, NSError * error);

@interface ADHWebDebugActionService ()

@property (nonatomic, strong) NSString * lastJs;

@end

@implementation ADHWebDebugActionService

+ (NSString *)serviceName {
    return @"adh.webconsole";
}

//filesystem - @selector(onRequestFileSystem:)
+ (NSDictionary<NSString*,NSString *> *)actionList {
    return @{
             @"setup" : NSStringFromSelector(@selector(onRequestSetup:)),
             @"teardown" : NSStringFromSelector(@selector(onRequestTeardown:)),
             @"jscall" : NSStringFromSelector(@selector(onRequestRunJS:)),
             };
}

- (void)onRequestSetup: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        id webView = nil;
        NSDictionary *body = request.body;
        NSString * webAddr = body[@"webaddr"];
        webView = [self getViewWithAddress:webAddr];
        if(webView) {
            [ADHWebDebugService.service setupWebView:webView];
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            data[@"success"] = adhvf_const_strtrue();
            [request finishWithBody:data];
        }else {
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            data[@"success"] = adhvf_const_strfalse();
            data[@"msg"] = @"sorry, webview not found";
            [request finishWithBody:data];
        }
    });
}

- (void)onRequestTeardown: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        id webView = nil;
        NSDictionary *body = request.body;
        NSString * webAddr = body[@"webaddr"];
        webView = [self getViewWithAddress:webAddr];
        if(webView) {
            [ADHWebDebugService.service teardownWebView:webView];
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            data[@"success"] = adhvf_const_strtrue();
            [request finishWithBody:data];
        }else {
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            data[@"success"] = adhvf_const_strfalse();
            data[@"msg"] = @"sorry, webview not found";
            [request finishWithBody:data];
        }
    });
}

- (void)onRequestRunJS: (ADHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        id webView = nil;
        NSDictionary *body = request.body;
        NSString * webAddr = body[@"webaddr"];
        if(webAddr) {
            webView = [self getViewWithAddress:webAddr];
        }
        NSString * js = request.body[@"js"];
        if(webView){
            [self runJs:js webView:webView onCompletion:^(NSString *result, NSError *error) {
                NSMutableDictionary * data = [NSMutableDictionary dictionary];
                if(error){
                    data[@"success"] = adhvf_const_strfalse();
                    data[@"msg"] = [NSString stringWithFormat:@"%@",error.localizedDescription];
                }else{
                    data[@"success"] = adhvf_const_strtrue();
                    data[@"response"] = adhvf_safestringfy(result);
                }
                [self responseRunJsRequest:request withResult:data];
            }];
        }else{
            NSMutableDictionary * data = [NSMutableDictionary dictionary];
            data[@"success"] = adhvf_const_strfalse();
            data[@"msg"] = @"sorry, webview not found";
            [self responseRunJsRequest:request withResult:data];
        }
    });
}

- (UIView *)getViewWithAddress: (NSString *)insAddr {
    NSScanner *scanner = [NSScanner scannerWithString:insAddr];
    unsigned long long addr;
    [scanner scanHexLongLong:&addr];
    id instance = (__bridge id)((const void*)addr);
    UIView *view = nil;
    if([instance isKindOfClass:[ADHWeakView class]]) {
        ADHWeakView *weakView = (ADHWeakView *)instance;
        view = weakView.targetView;
    }
    return view;
}

- (void)runJs: (NSString *)js webView: (id)webView onCompletion: (ADHWebDebugCompletion)completion
{
    NSString * encodedJs = [[js dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]; // base64 encode
    NSString * cmd = [NSString stringWithFormat:@"\
                      var result ='';\
                      var value = eval(decodeURIComponent(escape(window.atob('%@'))));\
                      if(typeof(value)=='object'){\
                      result = JSON.stringify(value,null,4);\
                      }else{\
                      result = value.toString();\
                      }\
                      result;\
                      ",encodedJs];
    if([webView isKindOfClass:[WKWebView class]]){
        WKWebView * wkweb = webView;
        [wkweb evaluateJavaScript:cmd completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(completion){
                if(error){
                    completion(result,error);
                }else{
                    NSString * resultStr = [NSString stringWithFormat:@"%@",result];
                    completion(resultStr,error);
                }
            }
        }];
    }
}

- (void)responseRunJsRequest: (ADHRequest *)request withResult: (NSDictionary *)result {
    [request finishWithBody:result];
}

@end
















