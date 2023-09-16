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
- (void)requestWithService: (nonnull NSString *)service
                    action: (nonnull NSString *)action
                      body: (nullable NSDictionary *)body
                   payload: (nullable NSData *)payload
           progressChanged: (nullable ADHApiClientProgressBlock)progressBlock
                 onSuccess: (nullable ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (nullable ADHApiClientFailedBlock)failedCallback;

//no progress
- (void)requestWithService: (nonnull NSString *)service
                    action: (nonnull NSString *)action
                      body: (nullable NSDictionary *)userInfo
                 onSuccess: (nullable ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (nullable ADHApiClientFailedBlock)failedCallback;

- (void)requestWithService: (nonnull NSString *)service
                    action: (nonnull NSString *)action
                 onSuccess: (nullable ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (nullable ADHApiClientFailedBlock)failedCallback;


- (void)requestWithService: (nonnull NSString *)service
                    action: (nonnull NSString *)action
                      body: (nullable NSDictionary *)body
           progressChanged: (nullable ADHApiClientProgressBlock)progressBlock
                 onSuccess: (nullable ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (nullable ADHApiClientFailedBlock)failedCallback;

- (void)requestWithService: (nonnull NSString *)service
                    action: (nonnull NSString *)action
           progressChanged: (nullable ADHApiClientProgressBlock)progressBlock
                 onSuccess: (nullable ADHApiClientRequestSuccessBlock)successCallback
                  onFailed: (nullable ADHApiClientFailedBlock)failedCallback;



//Server Api
- (void)responseSession: (nonnull ADHSession *)session
               withBody: (nonnull NSDictionary *)body
                payload: (nullable NSData *)payload
        progressChanged: (nullable ADHApiClientProgressBlock)progressBlock
              onSuccess: (nullable ADHApiClientResponseSuccessBlock)successCallback
               onFailed: (nullable ADHApiClientFailedBlock)failedCallback;


@end





















