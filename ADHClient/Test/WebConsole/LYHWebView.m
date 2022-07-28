//
//  LYHWebView.m
//  magapp-x
//
//  Created by 陆文龙 on 2019/2/28.
//  Copyright © 2019年 lyeah. All rights reserved.
//

#import "LYHWebView.h"
#import "WKWebViewJavascriptBridge.h"

static NSString * const kLYHWebViewProgressKVO     = @"estimatedProgress";
static NSString * const kLYHWKCookies              = @"com.lyeah.webcookies";

@implementation LYHProcessPool

+ (instancetype)processPool
{
    static LYHProcessPool *processPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processPool = [[LYHProcessPool alloc] init];
    });
    return processPool;
}

@end

@interface LYHWebView ()<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) id webView;
@property (nonatomic, assign, readwrite) LYHWebViewType webViewType;
@property (nonatomic, weak, nullable) id<LYHWebViewDelegate> lyh_delegate;
@property (nonatomic, strong, readwrite, nullable) id jsBridge;

@property (nonatomic, strong, readwrite, nullable) NSURLRequest *originRequest;
@property (nonatomic, strong, readwrite, nullable) NSURLRequest *currentRequest;
@property (nonatomic, readwrite) double estimatedProgress;
@property (nonatomic, assign) BOOL internal_scalesPageToFit;

@end

@implementation LYHWebView

- (instancetype)initWithWebViewType:(LYHWebViewType)type
{
    self = [super init];
    if (self) {
        if (@available(iOS 9.0, *)) {
            _webViewType = type;
        } else {
            _webViewType = LYHWebViewTypeUIWebView;
        }
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if ([self isUIWebView]) {
        [self initUIWebView];
    } else {
        [self initWKWebView];
    }
    [self setScalesPageToFit:YES];
}

- (void)initUIWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.allowsInlineMediaPlayback = YES;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = 1.0f;
    scrollView.scrollsToTop = YES;
    [self addSubview:webView];
    webView.frame = self.bounds;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView = webView;
}

- (void)initWKWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    configuration.userContentController = userContentController;
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    configuration.processPool = [LYHProcessPool processPool];
    configuration.allowsInlineMediaPlayback = YES;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.opaque = NO;
    webView.clipsToBounds = NO;
    webView.backgroundColor = [UIColor clearColor];
    UIScrollView *scrollView = webView.scrollView;
    scrollView.clipsToBounds = NO;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    scrollView.decelerationRate = 1.0f;
    scrollView.scrollsToTop = YES;
    [webView addObserver:self forKeyPath:kLYHWebViewProgressKVO options:NSKeyValueObservingOptionNew context:nil];
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [webView syncWKCookies:cookieStore];
    }
    [self addSubview:webView];
    webView.frame = self.bounds;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView = webView;
}

- (BOOL)isUIWebView
{
    return self.webViewType == LYHWebViewTypeUIWebView;
}

- (BOOL)isWKWebView
{
    return self.webViewType == LYHWebViewTypeWKWebView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kLYHWebViewProgressKVO]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
        [self internal_webViewDidUpdateProgress:self.estimatedProgress];
    }
}

- (id<LYHWebViewDelegate>)delegate
{
    return _lyh_delegate;
}

- (void)setDelegate:(id<LYHWebViewDelegate>)delegate
{
    _lyh_delegate = delegate;
    if ([self isUIWebView]) {
        UIWebView *webView = (UIWebView *)self.webView;
        webView.delegate = self;
        /*
        [WebViewJavascriptBridge enableLogging];
        WebViewJavascriptBridge *jsBridge = [WebViewJavascriptBridge bridgeForWebView:webView];
        [jsBridge setWebViewDelegate:self];
        self.jsBridge = jsBridge;
         */
    } else {
        WKWebView *webView = (WKWebView *)self.webView;
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        /*
        [WKWebViewJavascriptBridge enableLogging];
        WKWebViewJavascriptBridge *jsBridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
        [jsBridge setWebViewDelegate:self];
        self.jsBridge = jsBridge;
         */
    }
}

#pragma mark ---------- UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self internal_webViewDidStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.originRequest) {
        self.originRequest = webView.request;
    }
    [self internal_webViewDidFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.currentRequest = request;
    BOOL result = [self internal_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return result;
}

#pragma mark ----------- WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    self.currentRequest = navigationAction.request;
    BOOL result = [self internal_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if (result) {
        if (!navigationAction.targetFrame) {
            [self loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (@available(iOS 12.0, *)) {
        // iOS 11 也有这种获取方式，但是 iOS 11 可以在response里面直接获取到，只有 iOS 12 获取不到
        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
//            DHLog("WKHTTPCookieStore中的cookie：%@", cookies);
            [webView insertCookies:cookies];
        }];
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//        DHLog("WKNavigationResponse中的cookie：%@", cookies);
        [webView insertCookies:cookies];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self internal_webViewDidStartLoad];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    [dataStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
//                             DHLog(@"WKWebsiteDataRecord：%@",[record description]);
                         }
                     }];
    [self internal_webViewDidFinishLoad];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self internal_webViewDidFailLoadWithError:error];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self internal_webViewWebContentProcessDidTerminate];
}

#pragma mark ---------- WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        self.currentRequest = navigationAction.request;
        [self loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    [self internal_webViewShowTextInputAlertWithMessage:prompt placeholder:defaultText completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    [self internal_webViewShowConfirmAlertWithMessage:message completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(void))completionHandler
{
    [self internal_webViewShowAlertWithMessage:message completionHandler:completionHandler];
}

#pragma mark ---------- internal LYHWebView Delegate

- (void)internal_webViewDidFinishLoad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
}

- (void)internal_webViewDidStartLoad
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
}

- (void)internal_webViewDidFailLoadWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}

- (BOOL)internal_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        result = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return result;
}

- (void)internal_webViewWebContentProcessDidTerminate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        [self.delegate webViewWebContentProcessDidTerminate:self];
    }
}

- (void)internal_webViewShowTextInputAlertWithMessage:(NSString *)message placeholder:(NSString *)placeholder completionHandler:(void (^)(NSString *result))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showTextInputAlertWithMessage:placeholder:completionHandler:)]) {
        [self.delegate webView:self showTextInputAlertWithMessage:message placeholder:placeholder completionHandler:completionHandler];
    }
}

- (void)internal_webViewShowConfirmAlertWithMessage:(NSString *)message completionHandler:(void (^)(BOOL result))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showConfirmAlertWithMessage:completionHandler:)]) {
        [self.delegate webView:self showConfirmAlertWithMessage:message completionHandler:completionHandler];
    }
}

- (void)internal_webViewShowAlertWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:showAlertWithMessage:completionHandler:)]) {
        [self.delegate webView:self showAlertWithMessage:message completionHandler:completionHandler];
    }
}

- (void)internal_webViewDidUpdateProgress:(double)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)]) {
        [self.delegate webView:self didUpdateProgress:progress];
    }
}

- (UIScrollView *)scrollView
{
    UIScrollView *scrollView = nil;
    if ([self isUIWebView]) {
        scrollView = ((UIWebView *)self.webView).scrollView;
    } else {
        scrollView = ((WKWebView *)self.webView).scrollView;
    }
    return scrollView;
}

- (void)loadRequest:(NSURLRequest *)request
{
    if ([self isUIWebView]) {
        self.originRequest = request;
        self.currentRequest = request;
        UIWebView *webView = (UIWebView *)self.webView;
        [webView loadRequest:request];
    } else {
        WKWebView *webView = (WKWebView *)self.webView;
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        NSString *domain = mutableRequest.URL.host;
        if (domain) {
            WKUserScript *userScript = [webView searchCookieForUserScriptWithDomain:domain];
            [webView.configuration.userContentController addUserScript:userScript];
            NSString *requestCookie = [webView requestCookieStringWithDomain:domain];
            [mutableRequest setValue:requestCookie forHTTPHeaderField:@"Cookie"];
        }
        request = [mutableRequest copy];
        self.originRequest = request;
        self.currentRequest = request;
        [webView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) loadHTMLString:string baseURL:baseURL];
    } else {
        [((WKWebView *)self.webView) loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    } else {
        [((WKWebView *)self.webView) loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    }
}

- (NSURL*)URL
{
    if ([self isUIWebView]) {
        return ((UIWebView *)self.webView).request.URL;
    } else {
        return ((WKWebView *)self.webView).URL;
    }
}

- (BOOL)canGoBack
{
    BOOL canGoBack = NO;
    if ([self isUIWebView]) {
        canGoBack = ((UIWebView *)self.webView).canGoBack;
    } else {
        canGoBack = ((WKWebView *)self.webView).canGoBack;
    }
    return canGoBack;
}

- (BOOL)canGoForward
{
    BOOL canGoForward = NO;
    if ([self isUIWebView]) {
        canGoForward = ((UIWebView *)self.webView).canGoForward;
    } else {
        canGoForward = ((WKWebView *)self.webView).canGoForward;
    }
    return canGoForward;
}

- (BOOL)isLoading
{
    BOOL isLoading = NO;
    if ([self isUIWebView]) {
        isLoading = ((UIWebView *)self.webView).isLoading;
    } else {
        isLoading = ((WKWebView *)self.webView).isLoading;
    }
    return isLoading;
}

- (void)reload
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) reload];
    } else {
        [((WKWebView *)self.webView) reload];
    }
}

- (void)reloadFromOrigin
{
    if ([self isUIWebView]) {
        if (self.originRequest) {
            [self evaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')", self.originRequest.URL.absoluteString] completionHandler:nil];
        }
    } else {
        [((WKWebView *)self.webView) reloadFromOrigin];
    }
}

- (void)stopLoading
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) stopLoading];
    } else {
        [((WKWebView *)self.webView) stopLoading];
    }
}

- (void)goBack
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) goBack];
    } else {
        [((WKWebView *)self.webView) goBack];
    }
}

- (void)goForward;
{
    if ([self isUIWebView]) {
        [((UIWebView *)self.webView) goForward];
    } else {
        [((WKWebView *)self.webView) goForward];
    }
}

- (NSInteger)countOfHistory
{
    if ([self isUIWebView]) {
        int count = [[((UIWebView *)self.webView) stringByEvaluatingJavaScriptFromString:@"window.history.length"] intValue];
        if (count) {
            return count;
        } else {
            return 1;
        }
    } else {
        return ((WKWebView *)self.webView).backForwardList.backList.count;
    }
}

- (void)gobackWithStep:(NSInteger)step
{
    if (self.canGoBack == NO) return;
    if (step > 0) {
        NSInteger historyCount = self.countOfHistory;
        if (step >= historyCount) {
            step = historyCount - 1;
        }
        if ([self isUIWebView]) {
            [((UIWebView *)self.webView) stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.history.go(-%@)", @(step)]];
        } else {
            WKBackForwardListItem *backItem = ((WKWebView *)self.webView).backForwardList.backList[step];
            [((WKWebView *)self.webView) goToBackForwardListItem:backItem];
        }
    } else {
        [self goBack];
    }
}

- (BOOL)scalesPageToFit
{
    return _internal_scalesPageToFit;
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if ([self isUIWebView]) {
        ((UIWebView *)self.webView).scalesPageToFit = scalesPageToFit;
    } else {
        if (_internal_scalesPageToFit == scalesPageToFit) return;
        NSString *scaleScript =
        @"var head = document.getElementsByTagName('head')[0];\
        var hasViewPort = 0;\
        var metas = head.getElementsByTagName('meta');\
        for (var i = metas.length; i>=0 ; i--) {\
        var m = metas[i];\
        if (m.name == 'viewport') {\
        hasViewPort = 1;\
        break;\
        }\
        }; \
        if(hasViewPort == 0) { \
        var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        head.appendChild(meta);\
        }";
        WKUserContentController *userContentController = ((WKWebView *)self.webView).configuration.userContentController;
        NSMutableArray<WKUserScript *> *userScripts = [userContentController.userScripts mutableCopy];
        WKUserScript *targetUserScript = nil;
        for (WKUserScript *userScript in userScripts) {
            if ([userScript.source isEqualToString:scaleScript]) {
                targetUserScript = userScript;
                break;
            }
        }
        if (scalesPageToFit) {
            if (!targetUserScript) {
                targetUserScript = [[WKUserScript alloc] initWithSource:scaleScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
                [userContentController addUserScript:targetUserScript];
            }
        } else {
            if (targetUserScript) {
                [userScripts removeObject:targetUserScript];
            }
            [userContentController removeAllUserScripts];
            for (WKUserScript *aUserScript in userScripts) {
                [userContentController addUserScript:aUserScript];
            }
        }
    }
    _internal_scalesPageToFit = scalesPageToFit;
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler
{
    if ([self isUIWebView]) {
        NSString *result = [((UIWebView *)self.webView)stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    } else {
        [((WKWebView *)self.webView) evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    NSString *result = nil;
    if ([self isUIWebView]) {
        result = [((UIWebView *)self.webView) stringByEvaluatingJavaScriptFromString:javaScriptString];
    }
    return result;
}

- (void)dealloc
{
    if ([self isUIWebView]) {
        UIWebView *webView = (UIWebView *)self.webView;
        webView.delegate = nil;
        [webView loadHTMLString:@"" baseURL:nil];
        webView.scrollView.delegate = nil;
        [webView stopLoading];
        [webView removeFromSuperview];
    } else {
        WKWebView *webView = (WKWebView *)self.webView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        [webView removeObserver:self forKeyPath:kLYHWebViewProgressKVO];
        webView.scrollView.delegate = nil;
        [webView stopLoading];
        [webView removeFromSuperview];
    }
    self.jsBridge = nil;
}

@end

@implementation WKWebView (LYHWebCookie)

- (void)syncWKCookies:(WKHTTPCookieStore *)cookieStore
{
    NSMutableArray *cookies = [self sharedHTTPCookieStorage];
    if (cookies.count == 0)return;
    for (NSHTTPCookie *cookie in cookies) {
//        DHLog(@"%@", [cookie description]);
        [cookieStore setCookie:cookie completionHandler:nil];
    }
}

- (void)insertCookie:(NSHTTPCookie *)cookie
{
    @autoreleasepool {
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
            [cookieStore setCookie:cookie completionHandler:nil];
        }
        NSHTTPCookieStorage * shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [shareCookie setCookie:cookie];
        
        NSMutableArray *tempCookies = [NSMutableArray array];
        NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:kLYHWKCookies]];
        for (int i = 0; i < localCookies.count; i++) {
            NSHTTPCookie *tempCookie = [localCookies objectAtIndex:i];
            if ([cookie.name isEqualToString:tempCookie.name] &&
                [cookie.domain isEqualToString:tempCookie.domain]) {
                [localCookies removeObject:tempCookie];
                i--;
                break;
            }
        }
        [tempCookies addObjectsFromArray:localCookies];
        [tempCookies addObject:cookie];
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:tempCookies];
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kLYHWKCookies];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)insertCookies:(NSArray<NSHTTPCookie *> *)cookies
{
    if (cookies.count == 0) return;
    for (NSHTTPCookie *cookie in cookies) {
        [self insertCookie:cookie];
    }
}

- (NSMutableArray *)sharedHTTPCookieStorage
{
    @autoreleasepool {
        NSMutableArray *cookiesArr = [NSMutableArray array];
        /** 获取NSHTTPCookieStorage cookies  WKHTTPCookieStore 的cookie 已经同步*/
        NSHTTPCookieStorage * shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in shareCookie.cookies){
            [cookiesArr addObject:cookie];
        }
        /** 获取自定义存储的cookies */
        NSMutableArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:kLYHWKCookies]];
        //删除过期的cookies
        for (int i = 0; i < cookies.count; i++) {
            NSHTTPCookie *cookie = [cookies objectAtIndex:i];
            if (!cookie.expiresDate) {
                [cookiesArr addObject:cookie]; //当cookie布设置国旗时间时，视cookie的有效期为长期有效。
                continue;
            }
            if ([cookie.expiresDate compare:[NSDate dateWithTimeIntervalSinceNow:0]]) {
                [cookiesArr addObject:cookie];
            }else
            {
                [cookies removeObject:cookie]; //清除过期的cookie。
                i--;
            }
        }
        //存储最新有效的cookies
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: cookies];
        [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kLYHWKCookies];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return cookiesArr;
    }
}

- (void)clearWKCookies
{
    if (@available(iOS 11.0, *)) {
        NSSet *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    }
    //删除NSHTTPCookieStorage中的cookies
    NSHTTPCookieStorage *cookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookiesStore removeCookiesSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kLYHWKCookies];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))completionHandler
{
    if (@available(iOS 11.0, *)) {
        //删除WKHTTPCookieStore中的cookies
        WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
        [cookieStore deleteCookie:cookie completionHandler:nil];
    }
    //删除NSHTTPCookieStorage中的cookie
    NSHTTPCookieStorage *NSCookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [NSCookiesStore deleteCookie:cookie];
    //删除磁盘中的cookie
    NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:kLYHWKCookies]];
    for (int i = 0; i < localCookies.count; i++) {
        NSHTTPCookie *tempCookie = [localCookies objectAtIndex:i];
        if ([cookie.domain isEqualToString:tempCookie.domain] &&
            [cookie.domain isEqualToString:tempCookie.domain] ) {
            [localCookies removeObject:tempCookie];
            i--;
            break;
        }
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: localCookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kLYHWKCookies];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (completionHandler) {
        completionHandler();
    }
}

- (void)deleteWKCookiesByHost:(NSURL *)host completionHandler:(nullable void (^)(void))completionHandler
{
    if (@available(iOS 11.0, *)) {
        //删除WKHTTPCookieStore中的cookies
        WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * cookies) {
            NSArray *wkCookies = cookies;
            for (NSHTTPCookie *cookie in wkCookies) {
                NSURL *domainURL = [NSURL URLWithString:cookie.domain];
                if ([domainURL.host isEqualToString:host.host]) {
                    [cookieStore deleteCookie:cookie completionHandler:nil];
                }
            }
        }];
    }
    //删除NSHTTPCookieStorage中的cookies
    NSHTTPCookieStorage *NSCookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *NSCookies = NSCookiesStore.cookies;
    for (NSHTTPCookie *cookie in NSCookies) {
        
        NSURL *domainURL = [NSURL URLWithString:cookie.domain];
        if ([domainURL.host isEqualToString:host.host]) {
            [NSCookiesStore deleteCookie:cookie];
        }
    }
    //删除磁盘中的cookies
    NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kLYHWKCookies]];
    for (int i = 0; i < localCookies.count; i++) {
        NSHTTPCookie *tempCookie = [localCookies objectAtIndex:i];
        NSURL *domainURL = [NSURL URLWithString:tempCookie.domain];
        if ([host.host isEqualToString:domainURL.host]) {
            [localCookies removeObject:tempCookie];
            i--;
            break;
        }
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:localCookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:kLYHWKCookies];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (completionHandler) {
        completionHandler();
    }
}

- (NSString *)jsCookieStringWithDomain:(NSString *)domain
{
    @autoreleasepool {
        NSMutableString *cookieString = [NSMutableString string];
        NSArray *cookies = [self sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.domain containsString:domain]) {
                [cookieString appendString:[NSString stringWithFormat:@"document.cookie = '%@=%@';", cookie.name, cookie.value]];
            }
        }
        return cookieString;
    }
}

- (WKUserScript *)searchCookieForUserScriptWithDomain:(NSString *)domain
{
    NSString *cookie = [self jsCookieStringWithDomain:domain];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return cookieScript;
}

- (NSString *)requestCookieStringWithDomain:(NSString *)domain
{
    @autoreleasepool {
        NSMutableString *cookieString = [NSMutableString string];
        NSArray *cookies = [self sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.domain containsString:domain]) {
                [cookieString appendString:[NSString stringWithFormat:@"%@ = %@;", cookie.name, cookie.value]];
            }
        }
        if (cookieString.length > 1) {
            [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
        }
        return [cookieString copy];
    }
}

@end


