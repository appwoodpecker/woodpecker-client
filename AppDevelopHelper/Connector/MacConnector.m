//
//  ServerConnector.m
//  AppDevelopHelper
//
//  Created by 张小刚 on 2017/10/25.
//  Copyright © 2017年 lifebetter. All rights reserved.
//

#import "MacConnector.h"
#import "ADHProtocolConfig.h"
#import "DeviceUtil.h"
#import "AppContextManager.h"
#import "Preference.h"
#import "ADHAllowDeviceUtil.h"

@interface MacConnector() <ADHGCDAsyncSocketDelegate,NSNetServiceDelegate>

@property (nonatomic, strong) ADHGCDAsyncSocket * mSocket;
@property (nonatomic, strong) NSNetService * mNetService;
@property (nonatomic, strong) NSMutableArray * mClientApps;

@property (nonatomic, strong) ADHApiClient *mApiClient;
@property (nonatomic, strong) ADHProtocol *mProtocol;

@end

@implementation MacConnector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mApiClient = [[ADHApiClient alloc] init];
        self.mProtocol = [[ADHProtocol alloc] init];
        [self.mApiClient setProtocol:self.mProtocol];
    }
    return self;
}

- (void)disConnect
{
    if(self.mNetService){
        self.mNetService.delegate = nil;
        [self.mNetService stop];
        self.mNetService = nil;
    }
    if(self.mSocket){
        self.mSocket.delegate = nil;
        [self.mSocket disconnect];
        self.mSocket = nil;
    }
    [self.mClientApps removeAllObjects];
}

//start connect service
- (void)startService {
    [self disConnect];
    //setup socket
    ADHGCDAsyncSocket * socket = [[ADHGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    //由系统分配端口
    uint16_t port = 0;
    uint16_t preferedPort = [Preference preferedPort];
    if(preferedPort > 0) {
        port = preferedPort;
    }
    BOOL ret = [socket acceptOnPort:port error:&error];
    if(!ret){
        NSLog(@"%@",error);
        return;
    }
    self.mSocket = socket;
    self.mClientApps = [NSMutableArray array];
    //publish service
    NSString * deviceName = [DeviceUtil deviceName];
    NSString * serviceName = [NSString stringWithFormat:@"%@ (%@)",kADHNetServiceName,deviceName];
    NSNetService * netService = [[NSNetService alloc] initWithDomain:kADHNetServiceDomain type:kADHNetServiceType name:serviceName port:self.mSocket.localPort];
    NSData * txtData = [self txtRecordData];
    [netService setTXTRecordData:txtData];
    netService.delegate = self;
    self.mNetService = netService;
    [self.mNetService publish];
}

- (NSData *)txtRecordData {
    NSMutableDictionary * txtDic = [NSMutableDictionary dictionary];
    NSString * deviceName = [DeviceUtil deviceName];
    NSData * deviceData = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
    txtDic[@"name"] = deviceData;
    //device
    NSDictionary *allowDic = [DeviceUtil getDeviceAllowData];
    NSString *allowText = [allowDic adh_jsonPresentation];
    NSData *allowData = [allowText dataUsingEncoding:NSUTF8StringEncoding];
    txtDic[@"rule"] = allowData;
    NSData * txtData = [NSNetService dataFromTXTRecordDictionary:txtDic];
    return txtData;
}



- (void)updateAllowDevice {
    if(self.mNetService) {
        NSData *txtData = [self txtRecordData];
        [self.mNetService setTXTRecordData:txtData];
    }
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
//    NSLog(@"service will publish");
}

/* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
 */
- (void)netServiceDidPublish:(NSNetService *)sender
{
//    NSLog(@"service did publish , waiting for find");
}

/* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
 */
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
//    NSLog(@"service did not publish: %@",errorDict);
}

- (void)addApp: (ADHGCDAsyncSocket *)sock {
    [self.mProtocol setSocket:sock];
    NSString *remoteHost = [sock connectedHost];
    NSString *localHost = [sock localHost];
//    NSLog(@"remote: %@ local: %@",remoteHost,localHost);
    __weak typeof(self) wself = self;
    [self.mApiClient requestWithService:@"adh.appinfo" action:@"appinfo" body:nil payload:nil progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSDictionary * appInfo = body;
        BOOL allowed = NO;
        /**
         1.模拟器
         两种方法
         1. ip相同
         2. simhost值为同一用户
         */
        if(remoteHost && localHost && [remoteHost isEqualToString:localHost]) {
//            NSLog(@"same ip -> 模拟器");
            allowed = YES;
        }
        if(!allowed) {
            NSString * simhost = nil;
            if(appInfo[@"simhost"]) {
                simhost = appInfo[@"simhost"];
                //zhangxiaogang
                NSString *hostName = [DeviceUtil hostName];
                if([hostName isEqualToString:simhost]) {
//                    NSLog(@"sim host -> 模拟器");
                    allowed = YES;
                }
            }
        }
        /*
         2.usb直连
         169.254为link-local https://en.wikipedia.org/wiki/Link-local_address
         是Mac为连接的usb设备分配的ip
        */
        if(!allowed) {
            if([remoteHost hasPrefix:@"169.254"]) {
//                NSLog(@"usb设备");
                allowed = YES;
            }
        }
        //3.设备名称是否允许
        NSString * deviceName = appInfo[@"deviceName"];
        if(!allowed) {
            allowed = [ADHAllowDeviceUtil checkName:deviceName notDisallowed:[DeviceUtil getDeviceAllowData]];
        }
        if(!allowed) {
            //断开sock链接
            adhConsoleLog(@"Device is not allowed: %@",deviceName);
            [sock disconnect];
            return ;
        }
        NSString * bundleId = appInfo[@"bundleId"];
        NSString * appName = appInfo[@"appName"];
        NSString * systemVersion = appInfo[@"systemVersion"];
        NSString * frameworkVersion = appInfo[@"frameworkVersion"];
        ADHPlatform platform = ADHPlatformiOS;
        BOOL sandbox = NO;
        if(appInfo[@"platform"]) {
            platform = [appInfo[@"platform"] intValue];
            if(platform == ADHPlatformMacOS) {
                sandbox = [appInfo[@"sandbox"] boolValue];
            }
        }
        BOOL simulator = NO;
        if(appInfo[@"simulator"]) {
            simulator = [appInfo[@"simulator"] boolValue];
        }
        ADHApp * app = [[ADHApp alloc] init];
        app.socket = sock;
        app.deviceName = deviceName;
        app.appName = appName;
        app.bundleId = bundleId;
        app.systemVersion = systemVersion;
        app.frameworkVersion = frameworkVersion;
        app.platform = platform;
        app.sandbox = sandbox;
        app.simulator = simulator;
        NSArray *toolList = appInfo[@"apptoollist"];
        if(!toolList) {
            toolList = @[];
        }
        app.appToolList = toolList;
        //before add new app, try to remove the same bad app
        [wself tryRemoveTheSameApp:app];
        [wself.mClientApps addObject:app];
        if(wself.delegate && [wself.delegate respondsToSelector:@selector(connectorClientDidConnect:)]){
            [wself.delegate connectorClientDidConnect:app];
        }
    } onFailed:^(NSError *error) {
        
    } overSocket:sock];
}

/**
 * try to remove bad app
 * this will happen when the other socket closed without notify here, so the socket still looks good, but actually is broken.
 */
- (void)tryRemoveTheSameApp: (ADHApp *)theApp {
    ADHApp *badApp = nil;
    for (ADHApp * app in self.mClientApps) {
        if([app.deviceName isEqualToString:theApp.deviceName] && [app.bundleId isEqualToString:theApp.bundleId]) {
            //if same device, same app, we identify them the same.
            badApp = app;
            break;
        }
    }
    if(badApp) {
        [self.mClientApps removeObject:badApp];
    }
}

- (void)removeApp: (ADHGCDAsyncSocket *)sock
{
    ADHApp * app = [self appWithSocket:sock];
    if(app){
        [self.mClientApps removeObject:app];
    }
}

- (ADHApp *)appWithSocket: (ADHGCDAsyncSocket *)sock
{
    ADHApp * targetApp = nil;
    for (ADHApp * app in self.mClientApps) {
        if(app.socket == sock){
            targetApp = app;
            break;
        }
    }
    return targetApp;
}

- (NSArray<ADHApp *> *)appList
{
    return [NSArray arrayWithArray:self.mClientApps];
}

- (NSString *)localPort
{
    return [NSString stringWithFormat:@"%d",self.mSocket.localPort];
}


#pragma mark -----------------   manually disconnect app ----------------

- (void)disConnectApp: (ADHApp *)app {
    if(app.socket.isConnected) {
        [app.socket disconnect];
    }
    [self.mClientApps removeObject:app];
}


/**
 * 新的client连接
 */
- (void)socket:(ADHGCDAsyncSocket *)sock didAcceptNewSocket:(ADHGCDAsyncSocket *)newSocket
{
    [self addApp:newSocket];
}

/**
 * Server/Client
 * socket断开链接
 **/
- (void)socketDidDisconnect:(ADHGCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    ADHApp * app = [self appWithSocket:sock];
    if(app){
        [self removeApp:sock];
        if(self.delegate && [self.delegate respondsToSelector:@selector(connectorClientDidDisConnect:)]){
            [self.delegate connectorClientDidDisConnect:app];
        }
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(ADHGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    id<ADHGCDAsyncSocketDelegate> ioDelegate = [self getIODelegate:sock];
    if(ioDelegate && [ioDelegate respondsToSelector:@selector(socket:didWriteDataWithTag:)]){
        [ioDelegate socket:sock didWriteDataWithTag:tag];
    }
}

- (void)socket:(ADHGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    id<ADHGCDAsyncSocketDelegate> ioDelegate = [self getIODelegate:sock];
    if(ioDelegate && [ioDelegate respondsToSelector:@selector(socket:didReadData:withTag:)]){
        [ioDelegate socket:sock didReadData:data withTag:tag];
    }
}

- (NSTimeInterval)socket:(ADHGCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSTimeInterval interval = 0;
    id<ADHGCDAsyncSocketDelegate> ioDelegate = [self getIODelegate:sock];
    if(ioDelegate && [ioDelegate respondsToSelector:@selector(socket:shouldTimeoutReadWithTag:elapsed:bytesDone:)]){
        interval = [ioDelegate socket:sock shouldTimeoutReadWithTag:tag elapsed:elapsed bytesDone:length];
    }
    return interval;
}

- (NSTimeInterval)socket:(ADHGCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSTimeInterval interval = 0;
    id<ADHGCDAsyncSocketDelegate> ioDelegate = [self getIODelegate:sock];
    if(ioDelegate && [ioDelegate respondsToSelector:@selector(socket:shouldTimeoutWriteWithTag:elapsed:bytesDone:)]){
        [ioDelegate socket:sock shouldTimeoutWriteWithTag:tag elapsed:elapsed bytesDone:length];
    }
    return interval;
}

- (id<ADHGCDAsyncSocketDelegate>)getIODelegate: (ADHGCDAsyncSocket *)sock {
    NSArray<AppContext *>* contextList = [[AppContextManager manager] contextList];
    ADHProtocol *targetProtocol = nil;
    for (AppContext *context in contextList) {
        if(context.protocol.socket == sock) {
            targetProtocol = context.protocol;
            break;
        }
    }
    if(!targetProtocol) {
        if(self.mProtocol.socket == sock) {
            targetProtocol = self.mProtocol;
        }
    }
    return targetProtocol;
}

@end



