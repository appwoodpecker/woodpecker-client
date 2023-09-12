//
//  ADHProtocol.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2023/9/2.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHSession.h"
#import "ADHGCDAsyncSocket.h"
#import "ADHPTChannel.h"

@class ADHSocketChannel;
@class ADHUsbChannel;
@protocol ADHChannel <NSObject>

/**
 body: 主要数据(key,value)
 payload: 负载数据
 所有回调在protocol work queue
 */
- (void)requestWithBody:(NSDictionary *)body
                payload:(NSData *)payload
          onSendChanged:(ADHProtocolSessionProgress)sendProgressCallback
       onReceiveChanged:(ADHProtocolSessionProgress)receiveProgressCallback
              onSuccess:(ADHProtocolSessionSuccess)successCallback
               onFailed:(ADHProtocolSessionFailed)failedCallback;

- (void)responseSession:(ADHSession *)session
               withBody:(NSDictionary *)body
                payload:(NSData *)payload
          onSendChanged:(ADHProtocolSessionProgress)sendProgressCallback
              onSuccess:(ADHProtocolSessionSuccess)successCallback
               onFailed:(ADHProtocolSessionFailed)failedCallback;

- (BOOL)isSocket;
- (BOOL)isUsb;

@end

@protocol ADHChannelDelegate<NSObject>

@optional
- (void)protocolDidReceiveRequest: (ADHSession *)session;

@end

@interface ADHProtocol : NSObject

+ (ADHProtocol *)protocol;
- (void)setDelegete:(id<ADHChannelDelegate>)delegate;
- (id<ADHChannel>)workChannel;

- (void)setSocket:(ADHGCDAsyncSocket *)socket;
- (ADHSocketChannel *)socketChannel;

- (void)setUsb:(ADHPTChannel *)usbChannel;
- (ADHUsbChannel *)usbChannel;

- (BOOL)matchWithSocket:(ADHGCDAsyncSocket *)socket;
- (BOOL)matchWithUsb:(ADHPTChannel *)channel;

- (BOOL)isConnected;
- (void)disConnect;


@end
