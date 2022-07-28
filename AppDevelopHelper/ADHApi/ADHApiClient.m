//
//  ADHApiClient.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/4.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHApiClient.h"
#import "ADHProtocol.h"
#import "ADHDispatcher.h"

@interface ADHApiClient ()<ADHProtocolDelegate>

@property (nonatomic, weak) ADHProtocol * mProtocol;
@property (nonatomic, weak) ADHDispatcher *mDispatcher;

@end

@implementation ADHApiClient

+ (ADHApiClient *)sharedApi {
    static ADHApiClient * sharedApi = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApi = [[ADHApiClient alloc] init];
    });
    return sharedApi;
}

- (void)setProtocol: (ADHProtocol *)protocol
{
    self.mProtocol = protocol;
    self.mProtocol.delegate = self;
}

- (void)setDispatcher: (ADHDispatcher *)dispatcher {
    self.mDispatcher = dispatcher;
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)userInfo
                   payload: (NSData *)payload
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
                overSocket: (ADHGCDAsyncSocket *)socket
{
    NSMutableDictionary * body = [NSMutableDictionary dictionary];
    NSDictionary * serviceInfo = @{
                               @"service" : adhvf_safestringfy(service),
                               @"action" : adhvf_safestringfy(action),
                               };
    body[@"api"] = serviceInfo;
    if(!userInfo || ![userInfo isKindOfClass:[NSDictionary class]]) {
        userInfo = @{};
    }
    body[@"userinfo"] = userInfo;
    [self _requestWithBody:body payload:payload progressChanged:progressBlock onSuccess:successCallback onFailed:failedCallback overSocket:socket];
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)userInfo
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
                overSocket: (ADHGCDAsyncSocket *)socket
{
    [self requestWithService:service action:action body:userInfo payload:nil progressChanged:nil onSuccess:successCallback onFailed:failedCallback overSocket:socket];
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)userInfo
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
{
    [self requestWithService:service action:action body:userInfo payload:nil progressChanged:nil onSuccess:successCallback onFailed:failedCallback overSocket:nil];
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
{
    [self requestWithService:service action:action body:nil payload:nil progressChanged:nil onSuccess:successCallback onFailed:failedCallback overSocket:nil];
}

//with progress
- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)body
                   payload: (NSData *)payload
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
{
    [self requestWithService:service action:action body:body payload:payload progressChanged:progressBlock onSuccess:successCallback onFailed:failedCallback overSocket:nil];
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)body
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
{
    [self requestWithService:service action:action body:body payload:nil progressChanged:progressBlock onSuccess:successCallback onFailed:failedCallback overSocket:nil];
}

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback
{
    [self requestWithService:service action:action body:nil payload:nil progressChanged:progressBlock onSuccess:successCallback onFailed:failedCallback overSocket:nil];
}

//Client Api
- (void)_requestWithBody: (NSDictionary *)body
                payload: (NSData *)payload
        progressChanged: (ADHApiClientProgressBlock)progressBlock
              onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
               onFailed: (ADHApiClientFailedBlock)failedCallback
             overSocket: (ADHGCDAsyncSocket *)socket
{
    [self.mProtocol requestWithBody:body payload:payload onSendChanged:^(ADHSession *session) {
        [self performInMainQueue:^{
            if(progressBlock){
                progressBlock([session progress]);
            }
        }];
    } onReceiveChanged:^(ADHSession *session) {
        [self performInMainQueue:^{
            if(progressBlock){
                progressBlock([session progress]);
            }
        }];
    } onSuccess:^(ADHSession *session) {
        [self performInMainQueue:^{
            if(successCallback){
                ADHPResponse * response = session.response;
                NSDictionary *body = response.body;
                if(body[kADHApiErrorCodeKey]) {
                    NSInteger code = [body[kADHApiErrorCodeKey] integerValue];
                    NSError *error = [NSError errorWithDomain:kADHApiErrorUserDomain code:code userInfo:nil];
                    if(failedCallback){
                        failedCallback(error);
                    }
                }else {
                    successCallback(response.body,response.payload);
                }
            }
        }];
    } onFailed:^(ADHSession *session) {
        [self performInMainQueue:^{
            if(failedCallback){
                failedCallback(nil);
            }
        }];
    } overSocket:socket];
}

/**
 Server Api
 
 server dispatch request to different services on the protocol queue,
 after service finish handle a request, then response on the same protocol queue
 */
- (void)protocolDidReceiveRequest: (ADHSession *)session {
    //dispatch action
    [self.mDispatcher dispatchRequest:session apiClient:self onCompletion:^(NSDictionary * body,NSData * payload, ADHSession * session) {
        //response action
        [self responseSession:session withBody:body payload:payload progressChanged:nil onSuccess:nil onFailed:nil];
    }];
}

- (void)responseSession: (ADHSession *)session
               withBody: (NSDictionary *)body
                payload: (NSData *)payload
        progressChanged: (ADHApiClientProgressBlock)progressBlock
              onSuccess: (ADHApiClientResponseSuccessBlock)successCallback
               onFailed: (ADHApiClientFailedBlock)failedCallback
{
    if(!body){
        body = @{};
    }
//    NSLog(@"response session: %lld",session.tag);
    [self.mProtocol responseSession:session withBody:body payload:payload onSendChanged:^(ADHSession *session) {
        if(progressBlock){
            progressBlock(0.5);
        }
    } onSuccess:^(ADHSession *session) {
//        NSLog(@"response session succeed: %lld",session.tag);
        if(successCallback){
            successCallback();
        }
    } onFailed:^(ADHSession *session) {
//        NSLog(@"response session failed: %lld %@",session.tag,session.error);
        if(failedCallback){
            failedCallback(nil);
        }
    }];
}

#pragma mark -----------------   main queue   ----------------

- (void)performInMainQueue:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

@end








