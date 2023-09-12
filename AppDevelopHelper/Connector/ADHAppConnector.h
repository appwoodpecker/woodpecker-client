//
//  ClientConnector.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/25.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHGCDAsyncSocket.h"
#import "ADHRemoteService.h"
#import "ADHPTChannel.h"


extern NSString * const kADHConnectorConnectStatusUpdate;

@class ADHRemoteService;

//Search
typedef void (^ADHAppConnectorSearchUpdateBlock)(NSArray<ADHRemoteService *>* serviceList, BOOL moreComing);
typedef void (^ADHAppConnectorSearchFailedBlock)(NSError * error);
//Connec
typedef void (^ADHAppConnectorConnectSuccessBlock)(ADHGCDAsyncSocket * socket);
typedef void (^ADHAppConnectorConnectFailedBlock)(NSError * error);

@interface ADHAppConnector : NSObject

//USB连接
- (void)startUsbConnection;
//搜索服务
- (void)startSearchServiceWithUpdateBlock: (ADHAppConnectorSearchUpdateBlock)updateBlock error: (ADHAppConnectorSearchFailedBlock)errorBlock;
//停止搜索服务，主动停止外界接收不到回调事件
- (void)stopSearchService;

//连接remote service
- (void)connectToRemoteHost: (NSString *)host
                       port: (uint16_t)port
               successBlock: (ADHAppConnectorConnectSuccessBlock)successBlock
                 errorBlock:(ADHAppConnectorConnectFailedBlock)errorBlock;
//中断socket链接，主动close外界接收不到事件
- (void)closeConnection;

- (NSArray <ADHRemoteService *>*) serviceList;
- (ADHGCDAsyncSocket *)socket;

- (BOOL)isSearching;
- (BOOL)isConnecting;
- (BOOL)isSocketConnected;

- (NSString *)connectedHost;
- (uint16_t)connectedPort;

- (BOOL)isRemoteServiceConnected: (ADHRemoteService *)remoteService;

@property (nonatomic, weak) id <ADHGCDAsyncSocketDelegate> socketIODelegate;
@property (nonatomic, weak) id <ADHPTChannelDelegate> usbIODelegate;


- (BOOL)isUsbConnected;
- (ADHPTChannel *)usbChannel;

@end










