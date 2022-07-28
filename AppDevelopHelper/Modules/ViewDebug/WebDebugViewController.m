//
//  WebDebugViewController.m
//  WoodPecker
//
//  Created by 张小刚 on 2019/5/4.
//  Copyright © 2019 lifebetter. All rights reserved.
//

@import WebKit;
#import "WebDebugViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "ADHApiClient.h"
#import "ADHUserDefaultUtil.h"
#import "WebActionService.h"
#import "MacOrganizer.h"

@interface WebDebugViewController ()<WKUIDelegate>

@property (weak) IBOutlet WKWebView *webView;
@property (nonatomic, strong) WKWebViewJavascriptBridge * jsBridge;

@end

@implementation WebDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self setupJSBridge];
    [self loadContent];
    [self setupAppWebView];
}

- (void)setupAfterXib {
    [self.webView setValue: @NO forKey: @"drawsBackground"];
    self.webView.UIDelegate = self;
}

- (void)setupAppWebView {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    NSString *addr = self.webNode.weakViewAddr;
    if(addr) {
        body[@"webaddr"] = addr;
    }
    [self.apiClient requestWithService:@"adh.webconsole" action:@"setup" body:body payload:nil progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        
    } onFailed:^(NSError *error) {
        NSLog(@"register failed");
    }];
}

- (void)teardownAppWebView {
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    NSString *addr = self.webNode.weakViewAddr;
    if(addr) {
        body[@"webaddr"] = addr;
    }
    [self.apiClient requestWithService:@"adh.webconsole" action:@"teardown" body:body payload:nil progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSLog(@"teardown succeed");
    } onFailed:^(NSError *error) {
        NSLog(@"teardown failed");
    }];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveLog:) name:kWebActionServiceNewLog object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWebViewUpdate:) name:kWebActionServiceWebViewUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    NSString *theme = [Appearance isDark]? @"dark" : @"normal";
    [self webCall:@"onThemeUpdate" data:theme];
}

- (void)clearPreference {
    [ADHUserDefaultUtil emptyDomain:[self getPluginStorageDomain]];
}

- (void)setupJSBridge {
    WKWebViewJavascriptBridge * jsBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    //register method
    __weak typeof(self) wself = self;
    [jsBridge registerHandler:@"clientApi" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(![wself doCheckConnectionRoutine]){
            return;
        }
        NSString * service = data[@"service"];
        NSString * action = data[@"action"];
        NSDictionary * body = data[@"body"];
        NSData * payload = nil;
        NSString * payloadContent = data[@"payload"];
        if(payloadContent){
            payload = [[NSData alloc] initWithBase64EncodedString:payloadContent options:0];
        }
        [wself onJsCallWithService:service action:action body:body payload:payload jsCallback:responseCallback];
    }];
    [jsBridge registerHandler:@"localApi" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString * action = data[@"action"];
        NSDictionary * body = data[@"data"];
        [wself dispatchLocalApiWithAction:action data:body jsCallback:responseCallback];
    }];
    self.jsBridge = jsBridge;
}

- (void)onJsCallWithService: (NSString *)service
                     action: (NSString *)action
                       body: (NSDictionary *)body
                    payload: (NSData *)payload
                 jsCallback: (WVJBResponseCallback)jsCallback {
    NSMutableDictionary *mbody = [NSMutableDictionary dictionary];
    if(body) {
        [mbody addEntriesFromDictionary:body];
    }
    NSString *addr = self.webNode.weakViewAddr;
    if(addr) {
        mbody[@"webaddr"] = addr;
    }
    [self.apiClient requestWithService:service action:action body:mbody payload: payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSMutableDictionary * data = [NSMutableDictionary dictionary];
        if(body){
            data[@"data"] = body;
        }
        if(payload){
            NSString * base64Content = [payload base64EncodedStringWithOptions:0];
            data[@"payload"] = adhvf_safestringfy(base64Content);
        }
        jsCallback(data);
    } onFailed:^(NSError *error) {
        
    }];
}

#pragma mark -----------------   js action   ----------------

- (void)dispatchLocalApiWithAction: (NSString *)action data: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback {
    if([action isEqualToString:@"setPreference"]){
        [self localSetPreference:data jsCallback:responseCallback];
    }else if([action isEqualToString:@"getPreference"]){
        [self localGetPreference:data jsCallback:responseCallback];
    }else if([action isEqualToString:@"getTheme"]) {
        [self localGetTheme:data jsCallback:responseCallback];
    }
}

- (NSString *)getPluginStorageDomain {
    return [NSString stringWithFormat:@"adh_%@",@"WebDebug"];
}

- (void)localSetPreference: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback {
    NSString * key = data[@"key"];
    id value = data[@"value"];
    if(![key isKindOfClass:[NSString class]] || (key.length == 0)){
        return;
    }
    if(!value){
        return;
    }
    NSString * domain = [self getPluginStorageDomain];
    [ADHUserDefaultUtil setDefaultValue:value forKey:key inDomain:domain];
}

- (void)localGetPreference: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback {
    NSString * key = data[@"key"];
    id value = nil;
    if([key isKindOfClass:[NSString class]] && (key.length > 0)){
        NSString * domain = [self getPluginStorageDomain];
        value = [ADHUserDefaultUtil defaultValueForKey:key inDomain:domain];
    }
    responseCallback(value);
}

- (void)localGetTheme: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback {
    NSString *theme = nil;
    if([Appearance isDark]){
        theme = @"dark";
    }else {
        theme = @"normal";
    }
    responseCallback(theme);
}

- (void)loadContent {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"WebDebug" ofType:@"bundle"];
    NSString *pagePath = [bundlePath stringByAppendingPathComponent:@"index.html"];
    NSURL * requestURL = [NSURL fileURLWithPath:pagePath];
    NSURL *accessURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadFileURL:requestURL allowingReadAccessToURL:accessURL];
    //update console ui
    [self updateWebConsoleInfoUI];
}

#pragma mark -----------------   call plugin   ----------------

- (void)webCall: (NSString *)action data: (id)data {
    NSMutableDictionary * body = [NSMutableDictionary dictionary];
    body[@"name"] = action;
    if(data) {
        body[@"data"] = data;
    }
    [self.jsBridge callHandler:@"pluginCall" data:body];
}

- (void)onReceiveLog: (NSNotification *)noti {
    AppContext *context = noti.userInfo[@"context"];
    if(context != self.context) {
        return;
    }
    id object = noti.userInfo[@"message"];
    NSString *webAddr = noti.userInfo[@"webaddr"];
    if(![webAddr isEqualToString:self.webNode.instanceAddr]) {
        return;
    }
    [self webCall:@"log" data:object];
}

- (void)onWebViewUpdate: (NSNotification *)noti {
    AppContext *context = noti.userInfo[@"context"];
    if(context != self.context) {
        return;
    }
    __weak typeof(self) wself = self;
    NSString *webAddr = noti.userInfo[@"webaddr"];
    if(![webAddr isEqualToString:self.webNode.instanceAddr]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself updateWebConsoleInfoUI];
    });
}

- (void)updateWebConsoleInfoUI {
    if(!self.context.isConnected) return;
    NSDictionary * body = @{@"js":@"location.href"};
    __weak typeof(self) wself = self;
    [self.apiClient requestWithService:@"adh.webconsole" action:@"jscall" body:body onSuccess:^(NSDictionary *body, NSData *payload) {
        NSString * result = body[@"response"];
        if(!result) {
            result = adhvf_const_emptystr();
        }
        wself.view.window.title = result;
    } onFailed:^(NSError *error) {
        
    }];
}

#pragma mark -----------------   alert   ----------------

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
#if DEBUG
    NSLog(@"%@",message);
#endif
    completionHandler();
}

@end
