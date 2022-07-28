//
//  WebClientViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/19.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

@import WebKit;
#import "WebClientViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "ADHApiClient.h"
#import "ADHUserDefaultUtil.h"
#import "MacOrganizer.h"


@interface WebClientViewController ()<WKUIDelegate>

@property (weak) IBOutlet WKWebView *webView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, strong) WKWebViewJavascriptBridge * jsBridge;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *folderButton;

@end

@implementation WebClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAfterXib];
    [self addNotification];
    [self setupJSBridge];
    [self loadContent];
}

- (void)setupAfterXib {
    [self.webView setValue: @NO forKey: @"drawsBackground"];
    self.webView.UIDelegate = self;
#if DEBUG
//    [self clearPreference];
#endif
    [self updateAppearanceUI];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self.refreshButton setTintColor:[Appearance actionImageColor]];
    [self.folderButton setTintColor:[Appearance actionImageColor]];
    NSString *theme = [Appearance isDark]? @"dark" : @"normal";
    [self webCall:@"onThemeUpdate" data:theme];
}

- (void)loadContent {
    NSString * path = self.pluginPath;
    NSURL * requestURL = [NSURL fileURLWithPath:path];
    NSString * pluginHomePath = [[EnvtService service] pluginPath];
    NSURL * pluginHomeURL = [NSURL fileURLWithPath:pluginHomePath];
    [self.webView loadFileURL:requestURL allowingReadAccessToURL:pluginHomeURL];
}

- (void)clearPreference
{
    [ADHUserDefaultUtil emptyDomain:[self getPluginStorageDomain]];
}

- (void)setupJSBridge
{
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
                 jsCallback: (WVJBResponseCallback)jsCallback
{
    [self.apiClient requestWithService:service action:action body:body payload: payload progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
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
    }else if([action isEqualToString:@"webSnapshot"]) {
        [self webSnapshot:data jsCallback:responseCallback];
    }else if([action isEqualToString:@"getTheme"]) {
        [self localGetTheme:data jsCallback:responseCallback];
    }
}

- (NSString *)getPluginStorageDomain
{
    return [NSString stringWithFormat:@"adh_%@",self.pluginIdentifier];
}

- (void)localSetPreference: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback
{
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

- (void)localGetPreference: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback
{
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

- (void)webSnapshot: (NSDictionary *)data jsCallback: (WVJBResponseCallback)responseCallback {
    NSString * payloadContent = data[@"dataURL"];
    if(payloadContent){
        payloadContent = [payloadContent stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:payloadContent options:0];
        NSSavePanel *panel = [NSSavePanel savePanel];
        NSString *fileName = [ADHDateUtil formatStringWithDate:[NSDate date] dateFormat:@"yyyy-MM-dd hh-mm-ss"];
        fileName = [fileName stringByAppendingString:@".png"];
        panel.nameFieldStringValue = fileName;
        [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
            if(result == NSModalResponseOK) {
                NSURL *fileURL = panel.URL;
                NSError *error = nil;
                if(![data writeToURL:fileURL options:0 error:&error]) {
                    NSLog(@"%@",error);
                }
            }
        }];
    }
}

- (IBAction)refreshButtonPresse:(id)sender {
    [self loadContent];
}

- (IBAction)openButtonPressed:(id)sender {
    NSString * path = self.pluginPath;
    NSURL * fileURL = [NSURL fileURLWithPath:path];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
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

#pragma mark -----------------   alert   ----------------

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
#if DEBUG
    NSLog(@"%@",message);
#endif
    completionHandler();
}

@end













