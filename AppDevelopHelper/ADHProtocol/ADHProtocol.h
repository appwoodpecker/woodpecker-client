//
//  ADHProtocol.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHSession.h"
#import "ADHPackage.h"
#import "ADHGCDAsyncSocket.h"
#import "ADHDefine.h"

@protocol ADHProtocolDelegate;
@interface ADHProtocol : NSObject<ADHGCDAsyncSocketDelegate>

+ (ADHProtocol *)protocol;

/**
 传输底层socket
 对于Mac端来说，可以同时与多个App socket同时通信，此socket为当前工作socket
 对于App端，只有一个socket
 */
- (void)setSocket:(ADHGCDAsyncSocket *)socket;
- (ADHGCDAsyncSocket *)socket;
@property (nonatomic, weak) id <ADHProtocolDelegate> delegate;

- (dispatch_queue_t)workQueue;

/**
 body: 主要数据(key,value)
 payload: 负载数据
 所有回调在protocol work queue
 */
- (void)requestWithBody: (NSDictionary *)body
                        payload: (NSData *)payload
                  onSendChanged: (ADHProtocolSessionProgress)sendProgressCallback
               onReceiveChanged: (ADHProtocolSessionProgress)receiveProgressCallback
                      onSuccess: (ADHProtocolSessionSuccess)successCallback
                       onFailed: (ADHProtocolSessionFailed)failedCallback
                     overSocket: (ADHGCDAsyncSocket *)socket;

- (void)responseSession: (ADHSession *)session
                       withBody: (NSDictionary *)body
                        payload: (NSData *)payload
                  onSendChanged: (ADHProtocolSessionProgress)sendProgressCallback
                      onSuccess: (ADHProtocolSessionSuccess)successCallback
                       onFailed: (ADHProtocolSessionFailed)failedCallback;

@end


@protocol ADHProtocolDelegate<NSObject>

@optional
- (void)protocolDidReceiveRequest: (ADHSession *)session;

@end



