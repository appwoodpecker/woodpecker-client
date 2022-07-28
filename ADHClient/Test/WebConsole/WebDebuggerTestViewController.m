//
//  WebDebuggerTestViewController.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/12/17.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "WebDebuggerTestViewController.h"

@import WebKit;
@import UIKit;

@interface WebDebuggerTestViewController ()<WKUIDelegate>

@property (nonatomic, strong) WKWebView * wkWebView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation WebDebuggerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebview];
    [self loadContent];
}

- (void)setupWebview
{
    UIView * contentView = self.contentView;
    WKWebView * wkWebView = [[WKWebView alloc] init];
    wkWebView.UIDelegate = self;
    wkWebView.frame = contentView.bounds;
    wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:wkWebView];
    self.wkWebView = wkWebView;
}

- (void)loadContent {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"console" ofType:@"bundle"];
    NSBundle *consoleBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *url = [consoleBundle pathForResource:@"console" ofType:@"html"];
    NSURL * requestURL = [NSURL URLWithString:url];
    NSURL *fileURL = [NSURL fileURLWithPath:url];
    [self.wkWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

#pragma mark - uiwebview

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@",message);
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%@",message);
    completionHandler(YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

























