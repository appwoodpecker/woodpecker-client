//
//  NetworkViewController.m
//  ADHClient
//
//  Created by 张小刚 on 2017/12/6.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "NetworkTestViewController.h"
#import "ADHNetworkObserver.h"
#import "AFNetworking.h"
#import "NSData+Compress.h"

@import WebKit;

@interface NetworkTestViewController ()<NSURLConnectionDataDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) WKWebView * wkWebview;

@property (nonatomic, strong) NSMutableArray * connections;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation NetworkTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Network";
//    [[ADHNetworkObserver sharedObserver] start];
}

- (IBAction)sendRequestButtonPressed:(id)sender {
//    NSString * url = [NSString stringWithFormat:@"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32&t=%u",arc4random()];
    
    NSString * url = @"https://api.beta.crucio.hecdn.com/v10/discovery/gallery?$$ignore_signature=1&$$ignore_ua=1";
    NSURL * requestURL = [NSURL URLWithString:url];
    NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (IBAction)postButtonPressed:(id)sender {
    NSString * url = [NSString stringWithFormat:@"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32&t=%d&value=中国",arc4random()];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestURL];
    NSString * bodyText = @"brand=iPhone&brand_type=iPhone%206&net_type=4&os_version=12.4.1&slide_id=10011&source=app_ios_2.6.1&timestamp=1569417451000";
    NSData * body = [bodyText dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:60];
//    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
//    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (IBAction)sessionRequestButtonPressed:(id)sender {
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://api.github.com/emojis"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"session request finished");
    }];
    [task resume];
}

- (IBAction)sessionPostButtonPressed:(id)sender {
    // NSURLSession
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10.0;
    NSURLSession *mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSString * url = [NSString stringWithFormat:@"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32&t=%zd&value=中国",arc4random()];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest * uploadRequest = [NSMutableURLRequest requestWithURL:requestURL];
    uploadRequest.HTTPMethod = @"POST";
    NSData *data = [@"q=test" dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask * task = [mySession uploadTaskWithRequest:uploadRequest fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    [task resume];
}

- (IBAction)webviewButtonPressed:(id)sender {
    if(!self.webView){
        self.webView = [[UIWebView alloc] init];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString * url = @"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32";
    NSURL * requestURL = [NSURL URLWithString:url];
    NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
    [self.webView loadRequest:request];
}

- (IBAction)wkWebviewButtonPressed:(id)sender {
    if(!self.wkWebview){
        self.wkWebview = [[WKWebView alloc] init];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString * url = @"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32";
    NSURL * requestURL = [NSURL URLWithString:url];
    NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
    [self.wkWebview loadRequest:request];
}

- (IBAction)othersButtonPressed:(id)sender {
    [self sendExampleNetworkRequests];
}

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{

}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"[didSendBodyData]: %zd",totalBytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

}


- (void)sendExampleNetworkRequests
{
    // Async NSURLConnection
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/repos/Flipboard/FLEX/issues"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
    
    // Sync NSURLConnection
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lorempixel.com/320/480/"]] returningResponse:NULL error:NULL];
    });
    
    // NSURLSession
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10.0;
    NSURLSession *mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableArray *pendingTasks = [NSMutableArray array];
    
    // NSURLSessionDataTask with delegate
    [pendingTasks addObject:[mySession dataTaskWithURL:[NSURL URLWithString:@"http://cdn.flipboard.com/serviceIcons/v2/social-icon-flipboard-96.png"]]];
    
    // NSURLSessionDownloadTask with delegate
    [pendingTasks addObject:[mySession downloadTaskWithURL:[NSURL URLWithString:@"https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png?v5"]]];
    
    // Async NSURLSessionDownloadTask
    [pendingTasks addObject:[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:@"http://lorempixel.com/1024/1024/"] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
    }]];
    
    // Async NSURLSessionDataTask
    [pendingTasks addObject:[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://api.github.com/emojis"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }]];
    
    // Async NSURLSessionUploadTask
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com/"]];
    uploadRequest.HTTPMethod = @"POST";
    NSData *data = [@"q=test" dataUsingEncoding:NSUTF8StringEncoding];
    [pendingTasks addObject:[mySession uploadTaskWithRequest:uploadRequest fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }]];
    
    // Remaining requests made through NSURLConnection with a delegate
    NSArray *requestURLStrings = @[ @"http://lorempixel.com/400/400/",
                                    @"http://google.com",
                                    @"http://search.cocoapods.org/api/pods?query=FLEX&amount=1",
                                    @"https://api.github.com/users/Flipboard/repos",
                                    @"http://info.cern.ch/hypertext/WWW/TheProject.html",
                                    @"https://api.github.com/repos/Flipboard/FLEX/issues",
                                    @"https://cloud.githubusercontent.com/assets/516562/3971767/e4e21f58-27d6-11e4-9b07-4d1fe82b80ca.png",
                                    @"http://hipsterjesus.com/api?paras=1&type=hipster-centric&html=false",
                                    @"http://lorempixel.com/750/1334/" ];
    
    NSTimeInterval delayTime = 10.0;
    const NSTimeInterval stagger = 1.0;
    
    // Send off the NSURLSessionTasks (staggered)
    for (NSURLSessionTask *task in pendingTasks) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [task resume];
        });
        delayTime += stagger;
    }
    
    // Begin the NSURLConnection requests (staggered)
    self.connections = [NSMutableArray array];
    for (NSString *urlString in requestURLStrings) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [self.connections addObject:[[NSURLConnection alloc] initWithRequest:request delegate:self]];
        });
        delayTime += stagger;
    }
}

- (void)doURLSessionTest
{
    // NSURLSession
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10.0;
    NSURLSession *mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableArray *pendingTasks = [NSMutableArray array];
    /*
    // NSURLSessionDataTask with delegate
    [pendingTasks addObject:[mySession dataTaskWithURL:[NSURL URLWithString:@"http://cdn.flipboard.com/serviceIcons/v2/social-icon-flipboard-96.png"]]];
    
    // NSURLSessionDownloadTask with delegate
    [pendingTasks addObject:[mySession downloadTaskWithURL:[NSURL URLWithString:@"https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png?v5"]]];
    
    // Async NSURLSessionDownloadTask
    [pendingTasks addObject:[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:@"http://lorempixel.com/1024/1024/"] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
    }]];
    
    // Async NSURLSessionDataTask
    [pendingTasks addObject:[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://api.github.com/emojis"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }]];
    */
    // Async NSURLSessionUploadTask
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com/"]];
    uploadRequest.HTTPMethod = @"POST";
    NSData *data = [@"q=test" dataUsingEncoding:NSUTF8StringEncoding];
    [pendingTasks addObject:[mySession uploadTaskWithRequest:uploadRequest fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }]];
    
    NSTimeInterval delayTime = 10.0;
    const NSTimeInterval stagger = 1.0;
    
    // Send off the NSURLSessionTasks (staggered)
    for (NSURLSessionTask *task in pendingTasks) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [task resume];
        });
        delayTime += stagger;
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

- (IBAction)compressButtonPressed:(id)sender {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *serializer = [[AFJSONRequestSerializer alloc] init];
    
    manager.requestSerializer = serializer;
    NSString * url = [NSString stringWithFormat:@"https://api.github.com/emojis?circle_id=78&type_value=32&t=%u",arc4random()];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"deflate" forHTTPHeaderField:@"Content-Encoding"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *params = @{
                             @"a" : @"3",
                             @"b" : @"4",
                             };
    NSString * content = [params adh_jsonPresentation];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    data = [data zlibDeflate];
    [request setHTTPBody:data];
    NSURLSessionDataTask * task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@",responseObject?:error);
    }];
    self.task = task;
    [self.task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




