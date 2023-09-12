//
//  ADHUsbChannel.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2023/9/2.
//  Copyright © 2023 lifebetter. All rights reserved.
//

#import "ADHUsbChannel.h"
#import "ADHProtocolConfig.h"
#import "ADHPackage.h"
#import "ADHSession.h"


@interface ADHUsbChannel ()

@property (nonatomic, strong) ADHPTChannel* mChannel;
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ADHUsbChannel

+ (ADHUsbChannel *)channel {
    return [ADHUsbChannel new];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        static int nameIndex = 0;
        self.sessions = [NSMutableArray array];
        NSString *name = [NSString stringWithFormat:@"studio.lifebetter.usbchannel%@",(nameIndex > 0)?[NSString stringWithFormat:@"%d",nameIndex]:@""];
        self.queue = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
        nameIndex++;
    }
    return self;
}

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
               onFailed:(ADHProtocolSessionFailed)failedCallback {
    [self performTaskInQueue:^{
        ADHSession * session = [ADHSession session];
        session.localToRemote = YES;
        session.sendProgressCallback = sendProgressCallback;
        session.receiveProgressCallback = receiveProgressCallback;
        session.successCallback = successCallback;
        session.failedCallback = failedCallback;
        [session setTag];
        ADHPRequest * request = [[ADHPRequest alloc] init];
        session.request = request;
        request.session = session;
        request.body = body;
        request.payload = payload;
        [self.sessions addObject:session];
        [self startSession:session];
    }];
}

- (void)responseSession:(ADHSession *)session
               withBody:(NSDictionary *)body
                payload:(NSData *)payload
          onSendChanged:(ADHProtocolSessionProgress)sendProgressCallback
              onSuccess:(ADHProtocolSessionSuccess)successCallback
               onFailed:(ADHProtocolSessionFailed)failedCallback {
    [self performTaskInQueue:^{
        ADHPRequest * request = [[ADHPRequest alloc] init];
        session.request = request;
        request.session = session;
        request.body = body;
        request.payload = payload;
        session.sendProgressCallback = sendProgressCallback;
        session.successCallback = successCallback;
        session.failedCallback = failedCallback;
        [self startSession:session];
    }];
}

- (void)startSession:(ADHSession *)session {
    //将request数据生成数据包
    [self prepareRequestPackage:session];
    //发送
    [self sendRequestPackage:session];
}

/**
 将payload分成多个package
 */
- (void)prepareRequestPackage:(ADHSession *)session {
    [session.request unpack];
}

- (void)sendRequestPackage:(ADHSession *)session {
    session.status = SessionStatusSendRequest;
    [self doSendNextPackage:session];
}

- (void)doSendNextPackage:(ADHSession *)session {
    ADHPRequest * request = session.request;
    ADHPackage * nextPackage = [request nextPackage];
    if(nextPackage){
        NSData * data = [nextPackage packageData];
        uint32_t tag = session.tag;
        [self.mChannel sendFrameOfType:kADHUsbFrameTypeData tag:tag withPayload:data callback:^(NSError * _Nullable error) {
            [self onWritePackageComplete:tag error:error];
        }];
    }else{
        [self onFinishSendRequest:session];
    }
}

- (void)onFinishSendRequest:(ADHSession *)session {
    session.status = SessionStatusSendRequestFinish;
    if(session.isLocalToRemote){
        //如果是local发起的request，则期待remote响应
        [self doReceiveResponse:session];
    }else{
        //如果是remote发起请求，自己做完响应后结束
        if(session.successCallback){
            session.successCallback(session);
        }
        [self handleCompleteSession:session];
    }
}

- (ADHSession *)sessionWithTag: (long)tag {
    ADHSession * targetSession = nil;
    for (ADHSession * session in self.sessions) {
        if(session.tag == tag){
            targetSession = session;
            break;
        }
    }
    return targetSession;
}

/**
 * 发送包结束
 **/
- (void)onWritePackageComplete:(uint32_t)tag error:(NSError *)error {
    if (error != nil) {
        [self performTaskInQueue:^{
            ADHSession * session = [self sessionWithTag:tag];
            session.error = error;
            if(session){
                if(session.failedCallback){
                    session.failedCallback(session);
                }
            }
            [self handleFailedSession:session];
        }];
    } else {
        [self performTaskInQueue:^{
            ADHSession * session = [self sessionWithTag:tag];
            if(session){
                ADHPRequest * request = session.request;
                ADHPackage * package = [request workPackage];
                package.sended = YES;
                //更新进度
                if(session.sendProgressCallback){
                    session.sendProgressCallback(session);
                }
                [self doSendNextPackage:session];
            }
        }];
    }
}

#pragma mark -----------------   receive response   ----------------

- (void)doReceiveResponse:(ADHSession *)session {
    [self prepareReceiveResponse:session];
    session.status = SessionStatusReceiveResponse;
    [self doReceiveNextPackage:session];
}

- (void)prepareReceiveResponse: (ADHSession *)session {
    ADHPResponse * response = [[ADHPResponse alloc] init];
    response.packages = [NSMutableArray array];
    session.response = response;
    response.session = session;
}

/**
 开始接收下一个package
 */
- (void)doReceiveNextPackage: (ADHSession *)session {
    //do nothing
}


// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(ADHPTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(nullable NSData *)payload {
    [self performTaskInQueue:^{
        //解析包内容，根据第一个包，判断是否还有后续内容，直到结束
        ADHPackage * package = [ADHPackage packageWithData:payload];
        if(package){
            ADHSession * session = [self sessionWithTag:package.responseTag];
            if(!session){
                //接收到新的remote请求，创建新session准备
                session = [ADHSession session];
                session.localToRemote = NO;
                ADHPResponse * response = [[ADHPResponse alloc] init];
                response.packages = [NSMutableArray array];
                session.response = response;
                response.session = session;
                session.tag = package.responseTag;
                [self.sessions addObject:session];
                session.status = SessionStatusReceiveResponse;
//                NSLog(@"received tag: %lld",session.tag);
            }
            [self didReceivePackage:package session:session];
        } else{
            [self keepListening];
        }
    }];
}

/**
 read timeout
 return 0 means timeout on return
 */
/*
- (NSTimeInterval)socket:(ADHGCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    [self performTaskInQueue:^{
        //find session
        ADHSession * session = [self sessionWithTag:tag];
        if(session){
            NSError * error = [NSError errorWithDomain:kADHErrorDomain code:kADHErrorCodeTimeOut userInfo:@{NSLocalizedFailureReasonErrorKey:@"time out"}];
            session.error = error;
            if(session.failedCallback){
                session.failedCallback(session);
            }
        }
        [self handleFailedSession:session];
    }];
    return 0;
}*/

/**
 接收到一个package
 */
- (void)didReceivePackage:(ADHPackage *)package session:(ADHSession *)session {
    if(session.receiveProgressCallback){
        session.receiveProgressCallback(session);
    }
    ADHPResponse * response = session.response;
    if(package.isBody){
        response.body = package.body;
        response.payloadSize = package.responsePayloadSize;
    }
    [response.packages addObject:package];
    if(![response isEndPackage:package]){
        [self doReceiveNextPackage:session];
    }else{
        [self onResponseReceiveFinish:session];
    }
}

- (void)onResponseReceiveFinish: (ADHSession *)session {
    //组装完整response，这里有线程阻塞问题可能，尤其是iOS设备
    [session.response pack];
    session.status = SessionStatusReceiveResponseFinish;
    if(session.isLocalToRemote){
        if(session.successCallback){
            session.successCallback(session);
        }
        [self handleCompleteSession:session];
    }else{
        //remote to local 成功接收到消息，准备
        if(self.delegate && [self.delegate respondsToSelector:@selector(protocolDidReceiveRequest:)]){
            [self.delegate protocolDidReceiveRequest:session];
        }
    }
    //继续保持监听状态
    [self keepListening];
}

#pragma mark -----------------   handle finish session   ----------------

- (void)handleCompleteSession:(ADHSession *)session {
    [self.sessions removeObject:session];
}

- (void)handleFailedSession:(ADHSession *)session {
    [self.sessions removeObject:session];
}

/**
 保持处于监听request状态
 */
- (void)keepListening {

}

#pragma mark -----------------   util   ----------------

- (void)performTaskInQueue:(dispatch_block_t)block {
    dispatch_async(self.queue, block);
}

- (dispatch_queue_t)workQueue {
    return self.queue;
}

- (void)setUsb:(ADHPTChannel *)channel {
    self.mChannel = channel;
}

- (ADHPTChannel *)usb {
    return self.mChannel;
}

- (BOOL)isConnected {
    return self.mChannel.isConnected;
}

- (void)disConnect {
    [self.mChannel close];
}

- (BOOL)isUsb {
    return YES;
}

- (BOOL)isSocket {
    return NO;
}

@end
