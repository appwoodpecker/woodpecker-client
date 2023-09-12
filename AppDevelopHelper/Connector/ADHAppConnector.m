//
//  ClientConnector.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/25.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "ADHProtocolConfig.h"
#import "ADHAppConnector.h"
#import "ADHUtil.h"
#import "ADHPTChannel.h"

NSString * const kADHConnectorConnectStatusUpdate = @"ADHConnectorConnectStatusUpdate";

//bonjour服务发现超时
static const NSTimeInterval kADHConnectorServiceFindTimeout = 30;
//bonjour服务解析超时
static const NSTimeInterval kADHConnectorServiceResolveTimeout = 30;
//socket连接超时时间
static const NSTimeInterval kADHConnectorConnectTimeout = 30;

static const NSTimeInterval kADHUsbListenInterval = 0.3;

@interface ADHAppConnector ()<ADHGCDAsyncSocketDelegate,NSNetServiceBrowserDelegate,NSNetServiceDelegate, ADHPTChannelDelegate>

@property (nonatomic, strong) ADHGCDAsyncSocket * mSocket;
//根据type,domain搜索service(此时service地址TXTData还未resolve)
@property (nonatomic, strong) NSNetServiceBrowser * mNetServiceBrowser;
@property (nonatomic, strong) NSTimer * mSearchTimer;
//暂存搜索到的service，进行resolve address
@property (nonatomic, strong) NSMutableArray<NSNetService *>* mRemoteNetServices;
@property (nonatomic, assign) BOOL bSearching;

@property (nonatomic, strong) NSMutableArray<ADHRemoteService *>* mRemoteServices;

@property (nonatomic, strong) ADHAppConnectorSearchUpdateBlock searchUpdateBlock;
@property (nonatomic, strong) ADHAppConnectorSearchFailedBlock searchFailedBlock;

@property (nonatomic, strong) ADHAppConnectorConnectSuccessBlock connectSuccessBlock;
@property (nonatomic, strong) ADHAppConnectorConnectFailedBlock connectFailedBlock;

//当前(app)channel
@property (nonatomic, weak) ADHPTChannel *mChannel;
//对方(mac)channel
@property (nonatomic, weak) ADHPTChannel *mPeerChannel;


@end

@implementation ADHAppConnector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mRemoteServices = [NSMutableArray array];
        self.mRemoteNetServices = [NSMutableArray array];
        [self setupObserver];
    }
    return self;
}

- (void)setupObserver {
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self tryRecoverUsbConnectIfNeeded];
    }];
#else
    
#endif
}

- (BOOL)isConnecting {
    return self.mSocket && ![self.mSocket isConnected];
}

- (BOOL)isSocketConnected {
    return self.mSocket && [self.mSocket isConnected];
}

- (BOOL)isSearching {
    return (self.mNetServiceBrowser != nil);
}

- (NSString *)connectedHost {
    return self.mSocket.connectedHost;
}

- (uint16_t)connectedPort {
    return self.mSocket.connectedPort;
}

- (BOOL)isRemoteServiceConnected: (ADHRemoteService *)remoteService {
    BOOL ret = NO;
    BOOL connected = [self isSocketConnected];
    if(connected){
        NSString * remoteHost = self.mSocket.connectedHost;
        uint16_t remotePort = self.mSocket.connectedPort;
        if([remoteService.host isEqualToString:remoteHost] && remoteService.port == remotePort){
            ret = YES;
        }
    }
    return ret;
}

- (NSArray <ADHRemoteService *>*) serviceList {
    return [NSArray arrayWithArray:self.mRemoteServices];
}

- (ADHGCDAsyncSocket *)socket {
    return self.mSocket;
}

- (void)startUsbConnection {
    [self enqueueStartUsbListening];
}

//搜索服务
- (void)startSearchServiceWithUpdateBlock: (ADHAppConnectorSearchUpdateBlock)updateBlock error: (ADHAppConnectorSearchFailedBlock)failedBlock {
    self.searchUpdateBlock = nil;
    self.searchFailedBlock = nil;
    [self stopSearchService];
    if(!self.mNetServiceBrowser){
        self.mNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
        self.mNetServiceBrowser.delegate = self;
    }
    self.searchUpdateBlock = updateBlock;
    self.searchFailedBlock = failedBlock;
    [self.mNetServiceBrowser searchForServicesOfType:kADHNetServiceType inDomain:kADHNetServiceDomain];
    [self setSearchTimer];
}

//停止搜索服务
- (void)stopSearchService {
    [self.mRemoteServices removeAllObjects];
    [self.mRemoteNetServices removeAllObjects];
    [self.mNetServiceBrowser stop];
    self.mNetServiceBrowser = nil;
    self.bSearching = NO;
    [self clearSearchTimer];
}

- (void)setSearchTimer {
    [self clearSearchTimer];
    self.mSearchTimer = [NSTimer scheduledTimerWithTimeInterval:kADHConnectorServiceFindTimeout target:self selector:@selector(netServiceSearchTimeout) userInfo:nil repeats:NO];
}

- (void)clearSearchTimer {
    if(self.mSearchTimer) {
        [self.mSearchTimer invalidate];
        self.mSearchTimer = nil;
    }
}

- (void)netServiceSearchTimeout {
    if(self.mRemoteServices.count == 0) {
        if(self.searchFailedBlock){
            NSError * error = [NSError errorWithDomain:@"adh.servicesearch" code:001 userInfo:@{NSLocalizedFailureReasonErrorKey:@"search service timeout"}];
            self.searchFailedBlock(error);
        }
    }
}

#pragma mark -----------------   NetService Browser Delegate   ----------------

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    //find service, try resolve address
    [self.mRemoteNetServices addObject:service];
    service.delegate = self;
    self.bSearching = moreComing;
    [service resolveWithTimeout:kADHConnectorServiceResolveTimeout];
    [self clearSearchTimer];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
//    NSLog(@"did resove new address");
    NSArray<NSData *> * addresses = service.addresses;
//    for (NSData * address in addresses) {
//        NSString * host = [ADHGCDAsyncSocket hostFromAddress:address];
//        NSInteger port = [ADHGCDAsyncSocket portFromAddress:address];
//        NSLog(@"host: %@ port: %ld",host,port);
//    }
    if(addresses.count == 0){
        return;
    }
    NSData * address = nil;
    BOOL isSimulator = NO;
    //simulator?
    NSData *extractedExpr = [self getSimulatorAddressData:addresses];
    NSData *simAddress = extractedExpr;
    if (simAddress != nil) {
        isSimulator = YES;
        address = simAddress;
    }
    if (address == nil) {
        address = [self getPreferedAddressData:addresses];
    }
    if (address == nil) {
        return;
    }
    NSString * host = [ADHGCDAsyncSocket hostFromAddress:address];
    uint16_t port = [ADHGCDAsyncSocket portFromAddress:address];
    //txtRecord available here
    NSData * txtRecordData = service.TXTRecordData;
    NSDictionary * txtDic = [NSNetService dictionaryFromTXTRecordData:txtRecordData];
    NSData * deviceData = txtDic[@"name"];
    NSString * serviceName = [[NSString alloc] initWithData:deviceData encoding:NSUTF8StringEncoding];
    NSData *rule = txtDic[@"rule"];
    NSDictionary *ruleData = nil;
    if(rule) {
        NSString *ruleTxt = [[NSString alloc] initWithData:rule encoding:NSUTF8StringEncoding];
        ruleData = [ruleTxt adh_jsonObject];
    }
    BOOL isExists = [self isRemoteServiceExists:host port:port serviceName:serviceName];
    if(!isExists){
        ADHRemoteService * service = [[ADHRemoteService alloc] init];
        service.name = serviceName;
        service.host = host;
        service.port = port;
        service.simulator = isSimulator;
        service.ruleData = ruleData;
//        NSLog(@"host: %@ port: %ld",host,port);
        [self.mRemoteServices addObject:service];
        //moreComing，有更多的service，或者有service正在resoving
        BOOL moreComing = self.bSearching;
        if(!moreComing) {
            BOOL bResoving = NO;
            NSInteger count = self.mRemoteNetServices.count;
            for (NSInteger i=0;i<count;i++) {
                NSNetService *service = self.mRemoteNetServices[count-1-i];
                if(service.TXTRecordData.length == 0) {
                    //mac端发布的service都有txtRecordData，为空说明正在resolve
                    bResoving = YES;
                    break;
                }
            }
            if(bResoving) {
                moreComing = YES;
            }
        }
        if(self.searchUpdateBlock){
            self.searchUpdateBlock([self serviceList],moreComing);
        }
    }
}

- (NSData *)getSimulatorAddressData: (NSArray *)addresses {
    if(addresses.count == 0) return nil;
    NSData * targetData = nil;
    //优先检查模拟器和usb直连
    for (NSData * address in addresses) {
        NSString * host = [ADHGCDAsyncSocket hostFromAddress:address];
        if([host isEqualToString:@"127.0.0.1"]) {
            targetData = address;
            break;
        }
    }
    return targetData;
}

- (NSData *)getUSBAddressData: (NSArray *)addresses {
    if(addresses.count == 0) return nil;
    NSData * targetData = nil;
    //优先检查模拟器和usb直连
    for (NSData * address in addresses) {
        NSString * host = [ADHGCDAsyncSocket hostFromAddress:address];
        if([host hasPrefix:@"169.254"]) {
            targetData = address;
            break;
        }
    }
    return targetData;
}

/**
 try the best possible address
 1. the same ip network
 2. ipv4
 //usb
 169.254.54.241 port: 56023
 fe80::8d7:1c3f:4aa3:365e port: 56023
 169.254.54.241 port: 56023
 fe80::8d7:1c3f:4aa3:365e port: 56023
 fe80::1408:b684:217a:5810 port: 56023
 192.168.0.102 port: 56023
 //模拟器
 127.0.0.1 port: 56023
 ::1 port: 56023
 fe80::1 port: 56023
 169.254.54.241 port: 56023
 fe80::8d7:1c3f:4aa3:365e port: 56023
 192.168.0.102 port: 56023
 fe80::1408:b684:217a:5810 port: 56023
 */
- (NSData *)getPreferedAddressData: (NSArray *)addresses {
    if(addresses.count == 0) return nil;
    NSData * targetData = nil;
    //优先检查模拟器和usb直连(usb目前有问题，暂时不支持）
    for (NSData * address in addresses) {
        NSString * host = [ADHGCDAsyncSocket hostFromAddress:address];
        if([host isEqualToString:@"127.0.0.1"]) {
            targetData = address;
            break;
        }
//        else if([host hasPrefix:@"169.254"]) {
//            targetData = address;
//            break;
//        }
    }
    if(targetData) {
        return targetData;
    }
    NSString *localIp = [ADHUtil getLocalIPAddress];
    if(localIp.length > 0) {
        NSInteger localComponentsCount = [localIp componentsSeparatedByString:@"."].count;
        NSInteger maxSameCount = 0;
        NSInteger possibleIndex = NSNotFound;
        for (NSInteger addrIndex = 0;addrIndex < addresses.count; addrIndex++) {
            NSData * data = addresses[addrIndex];
            NSString * host = [ADHGCDAsyncSocket hostFromAddress:data];
            NSInteger thisComponentsCount = [host componentsSeparatedByString:@"."].count;
            if(localComponentsCount != thisComponentsCount) {
                continue;
            }
            NSInteger maxLength = MIN(localIp.length, host.length) ;
            NSInteger sameCount = 0;
            for (NSInteger i=0; i<maxLength; i++) {
                NSRange range = NSMakeRange(0, i+1);
                NSString * letterA = [localIp substringWithRange:range];
                NSString *letterB = [host substringWithRange:range];
                if([letterA isEqualToString:letterB]) {
                    sameCount = i+1;
                }else {
                    break;
                }
            }
            if(sameCount > maxSameCount) {
                maxSameCount = sameCount;
                possibleIndex = addrIndex;
            }
        }
        if(possibleIndex == NSNotFound) {
            //not found
            for (NSInteger addrIndex = 0;addrIndex < addresses.count; addrIndex++) {
                NSData * data = addresses[addrIndex];
                NSString * host = [ADHGCDAsyncSocket hostFromAddress:data];
                NSInteger thisComponentsCount = [host componentsSeparatedByString:@"."].count;
                if(localComponentsCount == thisComponentsCount) {
                    possibleIndex = addrIndex;
                    break;
                }
            }
        }
        if(possibleIndex != NSNotFound) {
            targetData = addresses[possibleIndex];
        }
    }
    if(!targetData){
        targetData = addresses[0];
    }
    return targetData;
}

/* Sent to the NSNetService instance's delegate when an error in resolving the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants).
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
//    NSLog(@"did not resolve %@",errorDict);
}

/* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    if(self.searchFailedBlock){
        NSError * error = [NSError errorWithDomain:@"adh.servicesearch" code:002 userInfo:@{NSLocalizedFailureReasonErrorKey:@"search service failed"}];
        self.searchFailedBlock(error);
    }
    [self clearSearchTimer];
}

/* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
 */
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    if(self.searchFailedBlock){
        self.searchFailedBlock(nil);
    }
    [self clearSearchTimer];
}

- (BOOL)isRemoteServiceExists: (NSString *)remoteHost port:(uint16_t)remotePort serviceName: (NSString *)serviceName {
    BOOL isExists = NO;
    for (ADHRemoteService * service in self.mRemoteServices) {
        NSString * host = service.host;
        NSInteger port = service.port;
        if([host isEqualToString:remoteHost] && port == remotePort){
            isExists = YES;
            break;
        }
        if([serviceName isEqualToString:service.name]){
            isExists = YES;
            break;
        }
    }
    return isExists;
}

#pragma mark -----------------   socket connect   ----------------


//连接remote socket
- (void)connectToRemoteHost: (NSString *)host
                       port: (uint16_t)port
               successBlock: (ADHAppConnectorConnectSuccessBlock)successBlock
                 errorBlock:(ADHAppConnectorConnectFailedBlock)failedBlock {
    //断开前一个链接
    [self closeConnection];
    self.connectSuccessBlock = successBlock;
    self.connectFailedBlock = failedBlock;
    ADHGCDAsyncSocket * socket = [[ADHGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    BOOL ret = [socket connectToHost:host onPort:port withTimeout:kADHConnectorConnectTimeout error:&error];
    if(!ret){
        if(self.connectFailedBlock){
            self.connectFailedBlock(error);
        }
//        NSLog(@"%@",error);
    }
    self.mSocket = socket;
}

//中断socket链接
- (void)closeConnection {
    self.connectSuccessBlock = nil;
    self.connectFailedBlock = nil;
    self.mSocket.delegate = nil;
    if([self.mSocket isConnected]){
        [self.mSocket disconnect];
    }
    self.mSocket = nil;
}

/**
 连接server成功
 **/
- (void)socket:(ADHGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if(self.connectSuccessBlock){
        self.connectSuccessBlock(sock);
    }
    self.connectSuccessBlock = nil;
    self.connectFailedBlock = nil;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kADHConnectorConnectStatusUpdate object:self];
//    NSLog(@"client did connect");
}

/**
 * Server/Client
 * socket断开链接
 **/
- (void)socketDidDisconnect:(ADHGCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if(self.mSocket == sock){
        self.mSocket.delegate = self;
        self.mSocket = nil;
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        if(err){
            userInfo[NSUnderlyingErrorKey] = err;
        }
        if(self.connectFailedBlock) {
            self.connectFailedBlock(err);
        }
        self.connectSuccessBlock = nil;
        self.connectFailedBlock = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kADHConnectorConnectStatusUpdate object:self userInfo:userInfo];
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(ADHGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if(self.socketIODelegate && [self.socketIODelegate respondsToSelector:@selector(socket:didWriteDataWithTag:)]){
        [self.socketIODelegate socket:sock didWriteDataWithTag:tag];
    }
}

- (void)socket:(ADHGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if(self.socketIODelegate && [self.socketIODelegate respondsToSelector:@selector(socket:didReadData:withTag:)]){
        [self.socketIODelegate socket:sock didReadData:data withTag:tag];
    }
}

- (NSTimeInterval)socket:(ADHGCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSTimeInterval interval = 0;
    if(self.socketIODelegate && [self.socketIODelegate respondsToSelector:@selector(socket:shouldTimeoutReadWithTag:elapsed:bytesDone:)]){
        interval = [self.socketIODelegate socket:sock shouldTimeoutReadWithTag:tag elapsed:elapsed bytesDone:length];
    }
    return interval;
}

- (NSTimeInterval)socket:(ADHGCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSTimeInterval interval = 0;
    if(self.socketIODelegate && [self.socketIODelegate respondsToSelector:@selector(socket:shouldTimeoutWriteWithTag:elapsed:bytesDone:)]){
        interval = [self.socketIODelegate socket:sock shouldTimeoutWriteWithTag:tag elapsed:elapsed bytesDone:length];
    }
    return interval;
}

#pragma mark - USB

- (BOOL)isUsbConnected {
    return self.mPeerChannel.isConnected;
}

- (ADHPTChannel *)usbChannel {
    return self.mPeerChannel;
}

//连接USB，只有iOS支持
- (void)enqueueStartUsbListening {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enqueueStartUsbListening) object:nil];
    [self startUsbListening];
}

- (void)startUsbListening {
#if TARGET_OS_IPHONE
        //listening on our IPv4 port
        if (self.mChannel != nil) {
            self.mChannel.delegate = nil;
            [self.mChannel cancel];
            self.mChannel = nil;
        }
        ADHPTChannel *channel = [ADHPTChannel channelWithDelegate:self];
        [channel listenOnPort:kADHUsbPort IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
            if (error) {
//                NSLog(@"[Woodpecker USB] Failed to listen on 127.0.0.1:%d: %@", kADHUsbPort, error);
                [self performSelector:@selector(enqueueStartUsbListening) withObject:nil afterDelay:kADHUsbListenInterval];
            } else {
//                NSLog(@"[Woodpecker USB] Listening on 127.0.0.1:%d", kADHUsbPort);
                self.mChannel = channel;
            }
        }];
#endif
}

- (void)tryRecoverUsbConnectIfNeeded {
    /*
     lockscreen，长时间进入后台等，导致listen channel已经断开
     */
    if (![self isUsbConnected]) {
        [self performSelector:@selector(enqueueStartUsbListening) withObject:nil afterDelay:kADHUsbListenInterval];
    }
}

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(ADHPTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (channel != self.mPeerChannel) {
      // A previous channel that has been canceled but not yet ended. Ignore.
      return NO;
    }
    return YES;
}

// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(ADHPTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(NSData *)payload {
    [self.usbIODelegate ioFrameChannel:channel didReceiveFrameOfType:type tag:tag payload:payload];
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(ADHPTChannel*)channel didEndWithError:(NSError*)error {
    if (channel == self.mChannel) {
        /*
         listen channel断开
         - lockscreen
         - 进入后台
         会引起listen channel异常，重新设置一下
         */
//        NSLog(@"[Woodpecker USB] listen channel errror: %@",error);
        [self performSelector:@selector(enqueueStartUsbListening) withObject:nil afterDelay:kADHUsbListenInterval];
    } else if (channel == self.mPeerChannel) {
        /*
         连接断开
         - mac端关闭
         - lockscreen
         - 进入后台
         */
        if (self.mPeerChannel != nil) {
            self.mPeerChannel.delegate = nil;
            [self.mPeerChannel cancel];
        }
        self.mPeerChannel = nil;
//        NSLog(@"[Woodpecker USB] peer channel errror: %@",error);
        [[NSNotificationCenter defaultCenter] postNotificationName:kADHConnectorConnectStatusUpdate object:self userInfo:nil];
    }
}

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(ADHPTChannel*)channel didAcceptConnection:(ADHPTChannel*)otherChannel fromAddress:(ADHPTAddress*)address {
    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (self.mPeerChannel != nil) {
        self.mPeerChannel.delegate = nil;
      [self.mPeerChannel cancel];
    }
    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    self.mPeerChannel = otherChannel;
    self.mPeerChannel.userInfo = address;
//    NSLog(@"[Woodpecker USB] Connected to %@", address);
    [[NSNotificationCenter defaultCenter] postNotificationName:kADHConnectorConnectStatusUpdate object:self userInfo:nil];
}

@end
