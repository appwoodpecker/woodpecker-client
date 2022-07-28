//
//  FSWebViewController.m
//  WhatsInApp
//
//  Created by 张小刚 on 2017/5/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "FSWebViewController.h"
@import WebKit;

@interface FSWebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL needRepair;

@end

@implementation FSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareWebView];
    if(self.filePath){
        [self loadContent];
    }
    [self addNotification];
}

- (void)prepareWebView {
    if(self.needRepair) {
        if(self.webView) {
            [self.webView loadHTMLString:@"" baseURL:nil];
            [self.webView removeFromSuperview];
            self.webView = nil;
        }
        self.needRepair = NO;
    }
    if(!self.webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self.view addSubview:webView];
        self.webView = webView;
        [self.webView setValue: @NO forKey: @"drawsBackground"];
        self.webView.navigationDelegate = self;
    }
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceUI) name:[Appearance effectiveAppearance] object:nil];
}

- (void)updateAppearanceUI {
    [self reload];
}

- (void)reload {
    if(self.needRepair) {
        [self prepareWebView];
    }
    [self loadContent];
}

- (void)loadContent {
    if(!self.filePath) {
        [self.webView loadHTMLString:@"" baseURL:nil];
    }else {
        NSURL * fileURL = [NSURL fileURLWithPath:self.filePath];
        //can access to whole Documents(fix re-load another fileURL failed bug)
        NSURL *accessURL = [NSURL fileURLWithPath:[ADHFileUtil documentPath]];
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:accessURL];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //format not support
    NSString * tip = nil;
    NSString *fileName = [self.filePath lastPathComponent];
    NSString *textColor = nil;
    if([Appearance isDark]) {
        textColor = @"#FFF";
    }else {
        textColor = @"#000";
    }
    tip = [NSString stringWithFormat:NSLocalizedString(@"sandbox_webview_openfailed", nil),textColor,fileName];
    NSURL * fileURL = [NSURL fileURLWithPath:self.filePath];
    [self.webView loadHTMLString:tip baseURL:fileURL];
    self.needRepair = YES;
}

@end
