//
//  ADHSession.h
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/24.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADHPRequest.h"
#import "ADHPResponse.h"
#import "ADHDefine.h"

/**
 Session代表一次交互
 主动发送：
 先发送requeest，等待接收response，收到response结束
 被动接收：
 先收到respones，然后发送request，结束
 */

typedef NS_ENUM(NSUInteger, SessionStatus) {
    SessionStatusDefault,
    SessionStatusSendRequest,
    SessionStatusSendRequestFinish,
    SessionStatusReceiveResponse,
    SessionStatusReceiveResponseFinish
};

@class ADHGCDAsyncSocket;
@class ADHPTChannel;
@interface ADHSession : NSObject

@property (nonatomic, assign, getter=isLocalToRemote) BOOL localToRemote;

@property (nonatomic, strong) ADHPRequest * request;
@property (nonatomic, strong) ADHPResponse * response;

@property (nonatomic, assign) uint32_t tag;

@property (nonatomic, strong) ADHProtocolSessionProgress sendProgressCallback;
@property (nonatomic, strong) ADHProtocolSessionProgress receiveProgressCallback;
@property (nonatomic, strong) ADHProtocolSessionSuccess successCallback;
@property (nonatomic, strong) ADHProtocolSessionFailed failedCallback;

@property (nonatomic, strong) NSError * error;

+ (ADHSession *)session;
- (void)setTag;

@property (nonatomic, assign) SessionStatus status;

- (float)progress;


@end















