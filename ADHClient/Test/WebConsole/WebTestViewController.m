//
//  WebTestViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2019/3/4.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "WebTestViewController.h"
#import "LYHWebView.h"

@interface WebTestViewController ()<LYHWebViewDelegate>

@property (nonatomic, strong) LYHWebView *webView;

@end

@implementation WebTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.woodpeck.cn"]];
    [self.webView loadRequest:request];
}

- (void)setupUI {
    LYHWebView * webView = [[LYHWebView alloc] initWithWebViewType:LYHWebViewTypeWKWebView];
    webView.frame = self.view.bounds;
    [self.view addSubview:webView];
    webView.delegate = self;
    self.webView = webView;
}

- (BOOL)webView:(id<LYHWebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(id<LYHWebView>)webView {
    
}

- (void)webViewDidFinishLoad:(id<LYHWebView>)webView {
    
}

- (void)webView:(id<LYHWebView>)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webView:(id<LYHWebView>)webView didUpdateProgress:(CGFloat)progress {
    
}

- (void)webViewWebContentProcessDidTerminate:(id<LYHWebView>)webView {
    
}

- (void)webView:(id<LYHWebView>)webView showTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler {
    
}

- (void)webView:(id<LYHWebView>)webView showConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler {
    
}

- (void)webView:(id<LYHWebView>)webView showAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler {
    
}

@end
