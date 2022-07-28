//
//  MNetworkViewController.m
//  MacClient
//
//  Created by 张小刚 on 2019/5/26.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "MNetworkViewController.h"

@interface MNetworkViewController ()<NSURLConnectionDataDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableArray * connections;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation MNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)getButtonPressed:(id)sender {
    NSString * url = [NSString stringWithFormat:@"http://magapp.bbs.chihe.so/mag/wap/v1/wap/waphome/wsharelist?circle_id=78&type_value=32&t=%u",arc4random()];
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
    NSString * bodyText = @"key=1&value=%e4%b8%ad%e5%9b%bd";
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

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response {
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
    uploadRequest.HTTPMethod = @"GET";
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
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://magapp.bbs.chihe.so"]];
    uploadRequest.HTTPMethod = @"POST";
    [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData *data = [@"q=test" dataUsingEncoding:NSUTF8StringEncoding];
    [pendingTasks addObject:[mySession uploadTaskWithRequest:uploadRequest fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }]];
    
    NSTimeInterval delayTime = 1.0;
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


@end
