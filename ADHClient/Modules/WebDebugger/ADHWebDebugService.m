//
//  ConsoleService.m
//  ADHClient
//
//  Created by 张小刚 on 2018/5/26.
//  Copyright © 2018年 lifebetter. All rights reserved.
//

@import JavaScriptCore;
@import WebKit;
#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/queue.h>
#import "ADHNetworkUtility.h"
#import "ADHWebDebugService.h"
#import "ADHOrganizerPrivate.h"
#import "ADHViewDebugUtil.h"

@interface ADHWebDebugService ()<WKScriptMessageHandler>

@property (nonatomic, strong) NSString *jsSource;

@end

@implementation ADHWebDebugService

+ (ADHWebDebugService *)service {
    static ADHWebDebugService *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[ADHWebDebugService alloc] init];
    });
    return sharedService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadJsCode];
    }
    return self;
}

- (void)loadJsCode {
    NSBundle *mainBundle = [[ADHOrganizer sharedOrganizer] adhBundle];
    NSString *bundlePath = [mainBundle pathForResource:@"adhwebdebugger" ofType:@"bundle"];
    NSBundle *workBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *jsPath = [workBundle pathForResource:@"mock" ofType:@"js"];
    NSString *source = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    self.jsSource = source;
}

- (void)setupWebView: (id)webView {
    if([webView isKindOfClass:[WKWebView class]]) {
        [self doWKWebViewConsoleMock:webView];
    }
}

- (void)teardownWebView: (id)webView {
    if([webView isKindOfClass:[WKWebView class]]) {
        [self doWKWebViewConsoleCleanup:webView];
    }
}

#pragma mark - Delegate Injection

- (void)doWKWebViewConsoleMock: (WKWebView *)webview {
    WKWebViewConfiguration *configuration = webview.configuration;
    if(!configuration) {
        return;
    }
    NSString *source = self.jsSource;
    if(source.length == 0) return;
    /*
     * inject js
    */
    [webview evaluateJavaScript:source completionHandler:^(id _Nullable result, NSError * _Nullable error) {

    }];
    WKUserContentController *contentController = configuration.userContentController;
    //remove first
    [contentController removeScriptMessageHandlerForName:@"wkwebviewjsHandler"];
    [contentController addScriptMessageHandler:self name:@"wkwebviewjsHandler"];
}

- (void)doWKWebViewConsoleCleanup: (WKWebView *)webview {
    WKWebViewConfiguration *configuration = webview.configuration;
    if(!configuration) {
        return;
    }
    WKUserContentController *contentController = configuration.userContentController;
    [contentController removeScriptMessageHandlerForName:@"wkwebviewjsHandler"];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:@"wkwebviewjsHandler"]) {
        NSString *webAddr = [ADHViewDebugUtil stringWithInstance2:message.webView];
        [self doWebLog:message.body webview:webAddr];
    }
}

- (void)doWebLog: (id)object webview: (NSString *)webAddr {
    if(!object) return;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"message"] = object;
    if(webAddr) {
        body[@"webaddr"] = webAddr;
    }
    [[ADHApiClient sharedApi] requestWithService:@"adh.webservice" action:@"log" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}

- (void)doWebViewUpdate: (id)webview {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"type"] = NSStringFromClass([webview class]);
    if(webview) {
        body[@"webaddr"] = [ADHViewDebugUtil stringWithInstance2:webview];
    }
    [[ADHApiClient sharedApi] requestWithService:@"adh.webservice" action:@"webviewUpdate" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        
    }];
}


@end


