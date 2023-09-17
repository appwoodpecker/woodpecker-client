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
#import "ADHDispatcher+Default.h"
#import "ADHPTChannel.h"
#import "ADHPTUSBHub.h"
#import "ADHSocketChannel.h"
#import "ADHUsbChannel.h"
#import "ADHUsb.h"
#import "DeviceManager.h"


@interface MacConnector() <ADHGCDAsyncSocketDelegate,NSNetServiceDelegate, ADHPTChannelDelegate>

@property (nonatomic, strong) ADHGCDAsyncSocket * mSocket;
@property (nonatomic, strong) NSNetService * mNetService;
@property (nonatomic, strong) NSMutableArray * mClientApps;
//用于在正式连接前进行握手(是否可连、framework版本等)
@property (nonatomic, strong) NSMutableArray * mShakeApps;

//USB
@property (nonatomic, strong) dispatch_queue_t usbConnectedQueue;
@property (nonatomic, strong) NSMutableArray *mUsbs;

@property (nonatomic, strong) NSNumber *connectingToDeviceID;
@property (nonatomic, strong) NSNumber *connectedDeviceID;
@property (nonatomic, strong) NSDictionary *connectedDeviceProperties;
@property (nonatomic, strong) ADHPTChannel *connectedChannel;

@end

@implementation MacConnector

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)disConnect {
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
    self.mClientApps = [NSMutableArray array];
    self.mShakeApps = [NSMutableArray array];
    self.mUsbs = [NSMutableArray array];
    [self startSocketService];
    [self startUsbService];
}

- (void)startSocketService {
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

- (void)addAppWithSocket:(ADHGCDAsyncSocket *)sock usb:(ADHUsb *)usb {
    ADHApp *shakeApp = [self createShakeApp:sock usb:usb];
    [self.mShakeApps addObject:shakeApp];
    NSString *shakeId = shakeApp.shakeId;
    __weak typeof(self) wself = self;
    [shakeApp.apiClient requestWithService:@"adh.appinfo" action:@"appinfo" body:nil payload:nil progressChanged:nil onSuccess:^(NSDictionary *body, NSData *payload) {
        NSDictionary * appInfo = body;
        NSString * deviceName = appInfo[@"deviceName"];
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
        ADHApp *app = [self findShakeApp:shakeId];
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
        [wself.mShakeApps removeObject:app];
        if(wself.delegate && [wself.delegate respondsToSelector:@selector(connectorClientDidConnect:)]){
            [wself.delegate connectorClientDidConnect:app];
        }
    } onFailed:^(NSError *error) {
        
    }];
}


- (ADHApp *)createShakeApp:(ADHGCDAsyncSocket *)sock usb:(ADHUsb *)usb {
    ADHProtocol *protocol = [ADHProtocol protocol];
    [protocol setSocket:sock];
    [protocol setUsb:usb.channel];
    ADHApiClient *apiClient = [[ADHApiClient alloc] init];
    [apiClient setProtocol:protocol];
    ADHDispatcher *dispatcher = [ADHDispatcher macClientDispatcher];
    [apiClient setDispatcher:dispatcher];
    NSString *remoteHost = [sock connectedHost];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    ADHApp * app = [[ADHApp alloc] init];
    app.protocol = protocol;
    app.apiClient = apiClient;
    app.shakeId = [NSString stringWithFormat:@"%@-%.f",remoteHost,interval];
    app.usb = usb;
    return app;
}

- (ADHApp *)findShakeApp:(NSString *)shakeId {
    ADHApp *targetApp = nil;
    for (ADHApp *app in self.mShakeApps) {
        if ([app.shakeId isEqualToString:shakeId]) {
            targetApp = app;
            break;;
        }
    }
    return targetApp;
}

/**
 * try to remove bad app
 * this will happen when the other socket closed without notify here, so the socket still looks good, but actually is broken.
 */
- (void)tryRemoveTheSameApp:(ADHApp *)theApp {
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

- (void)removeAppWithSocket:(ADHGCDAsyncSocket *)sock usb:(ADHUsb *)usb {
    ADHApp * app = nil;
    if (sock != nil) {
        app = [self findAppWithSocket:sock];
    } else if (usb != nil) {
        app = [self findAppWithChannel:usb.channel];
    }
    if(app){
        [self.mClientApps removeObject:app];
        if(self.delegate && [self.delegate respondsToSelector:@selector(connectorClientDidDisConnect:)]){
            [self.delegate connectorClientDidDisConnect:app];
        }
    }
}

- (ADHApp *)findAppWithSocket:(ADHGCDAsyncSocket *)sock {
    ADHApp * targetApp = nil;
    for (ADHApp * app in self.mClientApps) {
        if([app.protocol matchWithSocket:sock]){
            targetApp = app;
            break;
        }
    }
    return targetApp;
}

- (ADHApp *)findAppWithChannel:(ADHPTChannel *)channel {
    ADHApp * targetApp = nil;
    for (ADHApp * app in self.mClientApps) {
        if([app.protocol matchWithUsb:channel]){
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

- (void)disConnectApp:(ADHApp *)app {
    [app.protocol disConnect];
    [self.mClientApps removeObject:app];
}


/**
 * 新的client连接
 */
- (void)socket:(ADHGCDAsyncSocket *)sock didAcceptNewSocket:(ADHGCDAsyncSocket *)newSocket {
    [self addAppWithSocket:newSocket usb:nil];
}

/**
 * Server/Client
 * socket断开链接
 **/
- (void)socketDidDisconnect:(ADHGCDAsyncSocket *)sock withError:(nullable NSError *)err {
    ADHApp * app = [self findAppWithSocket:sock];
    if(app){
        [self removeAppWithSocket:sock usb:nil];
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

- (id<ADHGCDAsyncSocketDelegate>)getIODelegate:(ADHGCDAsyncSocket *)sock {
    id<ADHGCDAsyncSocketDelegate> targetChannel = nil;
    for (ADHApp *app in self.mClientApps) {
        if([app.protocol matchWithSocket:sock]) {
            targetChannel = app.protocol.socketChannel;
            break;
        }
    }
    
    if(!targetChannel) {
        for (ADHApp *app in self.mShakeApps) {
            if([app.protocol matchWithSocket:sock]) {
                targetChannel = app.protocol.socketChannel;
                break;
            }
        }
    }
    return targetChannel;
}


#pragma mark USB

- (void)startUsbService {
    self.usbConnectedQueue = dispatch_queue_create("woodpecker.usbconnect", DISPATCH_QUEUE_SERIAL);
    // Start listening for device attached/detached notifications
    [self startListeningForDevices];
}

- (void)startListeningForDevices {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserverForName:ADHPTUSBDeviceDidAttachNotification object:ADHPTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *noti) {
        NSNumber *deviceID = [noti.userInfo objectForKey:ADHPTUSBHubNotificationKeyDeviceID];
        NSDictionary *properties = [noti.userInfo objectForKey:ADHPTUSBHubNotificationKeyProperties];
        NSString *udid = properties[@"UDID"];
//        NSLog(@"ADHPTUSBDeviceDidAttachNotification: %@", deviceID);
        [self onUsbAttatch:udid deviceId:deviceID];
    }];
    [nc addObserverForName:ADHPTUSBDeviceDidDetachNotification object:ADHPTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:ADHPTUSBHubNotificationKeyDeviceID];
//        NSLog(@"ADHPTUSBDeviceDidDetachNotification: %@", deviceID);
        [self onUsbDetatched:deviceID];
    }];
}

- (void)onUsbAttatch:(NSString *)udid deviceId:(NSNumber *)deviceId {
    ADHUsb *usb = [self findUsbWithUdid:udid];
    if (usb == nil) {
        usb = [ADHUsb new];
        usb.udid = udid;
        [self.mUsbs addObject:usb];
    }
    usb.deviceId = deviceId;
    usb.attatched = YES;
    usb.state = ADHUsbStateDisConnect;
    [self enqueueConnectToUSBDevice];
}

- (void)onUsbDetatched:(NSNumber *)deviceId {
    ADHUsb *usb = [self findUsbWithDeviceId:deviceId];
    if (usb == nil) {
        return;
    }
    [self removeAppWithSocket:nil usb:usb];
    if (usb.channel != nil) {
        [usb.channel close];
    }
    usb.channel = nil;
    usb.attatched = NO;
    usb.state = ADHUsbStateDisConnect;
}

- (void)enqueueConnectToUSBDevice {
    //cancel repeat schedule
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enqueueConnectToUSBDevice) object:nil];
    dispatch_async(self.usbConnectedQueue, ^{
        //根据测试，这里需要用main thread，如果不用再iOS lockscreen断开重新连接的时候不稳定
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToUSBDevice];
        });
    });
}

- (void)connectToUSBDevice {
    for (ADHUsb *usb in self.mUsbs) {
        if (usb.attatched && usb.state == ADHUsbStateDisConnect) {
            usb.state = ADHUsbStateConnecting;
            NSNumber *deviceId = usb.deviceId;
            if ([DeviceManager.shared isDeviceClosed:deviceId]) {
                continue;
            }
            ADHPTChannel *channel = [ADHPTChannel channelWithDelegate:self];
            channel.userInfo = usb.deviceId;
            [channel connectToPort:kADHUsbPort overUSBHub:ADHPTUSBHub.sharedHub deviceID:deviceId callback:^(NSError *error) {
                ADHUsb *usb = [self findUsbWithDeviceId:deviceId];
                if (error) {
                    if (error.domain == ADHPTUSBHubErrorDomain && error.code == ADHPTUSBHubErrorConnectionRefused) {
//                        NSLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
                    } else {
//                        NSLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
                    }
                    usb.state = ADHUsbStateDisConnect;
                } else {
                    usb.channel = channel;
                    usb.state = ADHUsbStateConnected;
                    [self addAppWithSocket:nil usb:usb];
//                    NSLog(@"connect success %@", deviceId);
                }
            }];
        }
    }
    [self performSelector:@selector(enqueueConnectToUSBDevice) withObject:nil afterDelay:kADHUsbReconnectDelay];
}

#pragma mark - PTChannelDelegate

- (void)ioFrameChannel:(ADHPTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(NSData *)payload {
    id<ADHPTChannelDelegate> ioDelegate = [self getUsbIODelegate:channel];
    [ioDelegate ioFrameChannel:channel didReceiveFrameOfType:type tag:tag payload:payload];
}

- (void)ioFrameChannel:(ADHPTChannel*)channel didEndWithError:(NSError*)error {
    ADHUsb *usb = [self findUsbWithChannel:channel];
    if (usb == nil) {
        return;
    }
    NSNumber *deviceId = usb.deviceId;
    [self removeAppWithSocket:nil usb:usb];
    usb.channel = nil;
    usb.state = ADHUsbStateDisConnect;
    BOOL shouldAutoConnect = (usb.attatched && error == nil);
    if ([DeviceManager.shared isDeviceClosed:deviceId]) {
        shouldAutoConnect = NO;
    }
    if (shouldAutoConnect) {
        //channel关闭，但是设备没有断开，尝试恢复链接
//        NSLog(@"Trying reconnect to %@", channel.userInfo);
        [self performSelector:@selector(enqueueConnectToUSBDevice) withObject:nil afterDelay:kADHUsbReconnectDelay];
    }
}

- (ADHUsb *)findUsbWithUdid:(NSString *)udid {
    ADHUsb *targetUsb = nil;
    for (ADHUsb *usb in self.mUsbs) {
        if ([usb.udid isEqualToString:udid]) {
            targetUsb = usb;
            break;
        }
    }
    return targetUsb;
}

- (ADHUsb *)findUsbWithDeviceId:(NSNumber *)deviceId {
    ADHUsb *targetUsb = nil;
    for (ADHUsb *usb in self.mUsbs) {
        if ([usb.deviceId isEqualTo:deviceId]) {
            targetUsb = usb;
            break;
        }
    }
    return targetUsb;
}

- (ADHUsb *)findUsbWithChannel:(ADHPTChannel *)channel {
    ADHUsb *targetUsb = nil;
    for (ADHUsb *usb in self.mUsbs) {
        if ([usb.channel isEqualTo:channel]) {
            targetUsb = usb;
            break;
        }
    }
    return targetUsb;
}

- (id<ADHPTChannelDelegate>)getUsbIODelegate:(ADHPTChannel *)channel {
    id<ADHPTChannelDelegate> targetChannel = nil;
    for (ADHApp *app in self.mClientApps) {
        if([app.protocol matchWithUsb:channel]) {
            targetChannel = app.protocol.usbChannel;
            break;
        }
    }
    
    if(!targetChannel) {
        for (ADHApp *app in self.mShakeApps) {
            if([app.protocol matchWithUsb:channel]) {
                targetChannel = app.protocol.usbChannel;
                break;
            }
        }
    }
    return targetChannel;
}


@end



