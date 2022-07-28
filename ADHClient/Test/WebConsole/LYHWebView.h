//
//  LYHWebView.h
//  magapp-x
//
//  Created by 陆文龙 on 2019/2/28.
//  Copyright © 2019年 lyeah. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LYHWebViewType) {
    LYHWebViewTypeUIWebView = 0,
    LYHWebViewTypeWKWebView,
};

@protocol LYHWebView;

@protocol LYHWebViewDelegate <NSObject>

@optional
- (BOOL)webView:(id<LYHWebView>)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(id<LYHWebView>)webView;
- (void)webViewDidFinishLoad:(id<LYHWebView>)webView;
- (void)webView:(id<LYHWebView>)webView didFailLoadWithError:(NSError *)error;
- (void)webView:(id<LYHWebView>)webView didUpdateProgress:(CGFloat)progress;
- (void)webViewWebContentProcessDidTerminate:(id<LYHWebView>)webView;
- (void)webView:(id<LYHWebView>)webView showTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler;
- (void)webView:(id<LYHWebView>)webView showConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler;
- (void)webView:(id<LYHWebView>)webView showAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;

@end

@protocol LYHWebView <NSObject>

@property (nonatomic, assign, readonly) BOOL isUIWebView;
@property (nullable, nonatomic, weak) id<LYHWebViewDelegate> delegate;
@property (nonatomic, strong, readonly) id jsBridge;//WebViewJavascriptBridge or WKWebViewJavascriptBridge

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nullable, nonatomic, strong, readonly) NSURLRequest *originRequest;
@property (nullable, nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nullable, nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, assign, readonly) BOOL canGoBack;
@property (nonatomic, assign, readonly) BOOL canGoForward;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, assign) BOOL scalesPageToFit;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

- (void)reload;
- (void)reloadFromOrigin;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;
- (void)gobackWithStep:(NSInteger)step;

- (NSInteger)countOfHistory;

/**
 支持UIWebView和WKWebView;
 UIWebView是同步回调，WKWebView是异步回调;
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^ _Nullable)(id _Nullable response, NSError *_Nullable error))completionHandler;

/**
 只支持UIWebView;
 */
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString;

@end

@interface LYHProcessPool : WKProcessPool

+ (instancetype)processPool;

@end

/**
 iOS 9.0 之前只使用 UIWebView;
 
 Feature            UIWebView       WKWebView
 JS执行速度             慢               快
 内存占用               大               小
 进度条                无               有
 Cookie             自动存储         需手动存储
 缓存                 有               无
 NSURLProtocol拦截    可以              不可以
 */
@interface LYHWebView : UIView<LYHWebView>

- (instancetype)initWithWebViewType:(LYHWebViewType)type;

@end

@interface WKWebView (LYHWebCookie)

/**
 iOS 11 同步cookies
 */
- (void)syncWKCookies:(WKHTTPCookieStore *)cookieStore API_AVAILABLE(ios(11.0));

/**
 插入cookies存储于磁盘
 */
- (void)insertCookie:(NSHTTPCookie *)cookie;

- (void)insertCookies:(NSArray<NSHTTPCookie *>*)cookies;

/**
 获取本地磁盘的cookies
 */
- (NSMutableArray *)sharedHTTPCookieStorage;

/**
 删除所有的cookies
 */
- (void)clearWKCookies;

/**
 删除某一个cookies
 */
- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))completionHandler;
- (void)deleteWKCookiesByHost:(NSURL *)host completionHandler:(nullable void (^)(void))completionHandler;

/**
 js获取domain的cookie
 */
- (NSString *)jsCookieStringWithDomain:(NSString *)domain;
- (WKUserScript *)searchCookieForUserScriptWithDomain:(NSString *)domain;

/**
 request请求获取domain的cookie
 */
- (NSString *)requestCookieStringWithDomain:(NSString *)domain;


@end

NS_ASSUME_NONNULL_END
