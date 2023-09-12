//
//  ADHApiClient.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/11/4.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHApiCommon.h"

typedef void (^ADHApiClientProgressBlock)(float progress);
typedef void (^ADHApiClientRequestSuccessBlock)(NSDictionary * body,NSData * payload);
typedef void (^ADHApiClientResponseSuccessBlock)(void);
typedef void (^ADHApiClientFailedBlock)(NSError *error);

/**
 终端接口
 所有回调转到主线程
 */
@class ADHGCDAsyncSocket;
@class ADHSession;
@interface ADHApiClient : NSObject

+ (ADHApiClient *)sharedApi;

- (void)setProtocol: (ADHProtocol *)protocol;
- (void)setDispatcher: (ADHDispatcher *)dispatcher;

//Client Api
- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)body
                   payload: (NSData *)payload
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback;

//no progress
- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)userInfo
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback;

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback;


- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
                      body: (NSDictionary *)body
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback;

- (void)requestWithService: (NSString *)service
                    action: (NSString *)action
           progressChanged: (ADHApiClientProgressBlock)progressBlock
                 onSuccess: (ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (ADHApiClientFailedBlock)failedCallback;



//Server Api
- (void)responseSession: (ADHSession *)session
               withBody: (NSDictionary *)body
                payload: (NSData *)payload
        progressChanged: (ADHApiClientProgressBlock)progressBlock
              onSuccess: (ADHApiClientResponseSuccessBlock)successCallback
               onFailed: (ADHApiClientFailedBlock)failedCallback;


@end





















