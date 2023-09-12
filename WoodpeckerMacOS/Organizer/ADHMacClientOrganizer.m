//
//  MacClientOrganizer.m
//  WoodpeckerMacOS
//
//  Created by 张小刚 on 2019/5/25.
//  Copyright © 2019 lifebetter. All rights reserved.
//

#import "ADHMacClientOrganizer.h"
#import "ADHMacGestureRecognizer.h"
#import "ADHMacWindow.h"
#import "ADHMacConnectViewController.h"
#import "ADHAppConnector.h"
#import "ADHPreferenceService.h"
#import "ADHLaunchOptions.h"
#import "ADHUserDefaultUtil.h"

#import "ADHMetaService.h"
#import "ADHKeepAliveService.h"
//server service
#import "ADHFileBrowserActionService.h"
#import "ADHUserDefaultsActionService.h"
#import "ADHAppInfoActionService.h"
#import "ADHAppDefaultActionService.h"
#import "ADHAppBundleActionService.h"
#import "ADHLocalizationActionService.h"
#import "ADHNotificationActionService.h"
#import "ADHNotificationObserver.h"
#import "ADHNetworkActionService.h"
#import "ADHConsoleActionService.h"
#import "ADHSocketChannel.h"


NSString * const kADHOrganizerWindowDidVisible = @"ADHOrganizerWindowDidVisible";
NSString * const kADHOrganizerWorkStatusUpdate = @"ADHOrganizerWorkStatusUpdate";

static NSInteger const ADHOrganizerAutoRecoverConnectionMaxCount = 3;
static NSTimeInterval const ADHOrganizerAutoConnectDelay = 0.1;

@interface ADHMacClientOrganizer ()<NSGestureRecognizerDelegate>

@property (nonatomic, strong) ADHLaunchOptions *launchOptions;
@property (nonatomic, strong) ADHProtocol *mProtocol;
@property (nonatomic, strong) ADHDispatcher *mDispatcher;
@property (nonatomic, strong) ADHAppConnector * mConnector;
@property (nonatomic, strong) ADHMacWindow *mWindow;


@property (nonatomic, strong) NSString * workingHost;
@property (nonatomic, assign) uint16_t workingPort;
@property (nonatomic, assign) BOOL shouldTryRecoverConnection;
@property (nonatomic, assign) NSInteger tryRecoverConnectionCounter;
@property (nonatomic, assign) BOOL bLaunchAutoConnectRoutine;
@property (nonatomic, assign) BOOL bLaunchAutoConnectUIAppeared;

@end

@implementation ADHMacClientOrganizer

+ (void)load {
    ADHMacClientOrganizer * organizer = [ADHMacClientOrganizer sharedOrganizer];
    [organizer setup];
}

+ (ADHMacClientOrganizer *)sharedOrganizer {
    static ADHMacClientOrganizer * organizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        organizer = [[ADHMacClientOrganizer alloc] init];
    });
    return organizer;
}

- (void)loadLaunchOptions {
    ADHLaunchOptions *options = [[ADHLaunchOptions alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:kADHAutoConnectEnabled]) {
        options.autoConnectEnabled = [defaults boolForKey:kADHAutoConnectEnabled];
    }
    if([defaults objectForKey:kADHHostName]) {
        options.hostName = [defaults stringForKey:kADHHostName];
    }
    if([defaults objectForKey:kADHHostAddress]) {
        NSString *addressName = [defaults stringForKey:kADHHostAddress];
        //移除空格
        addressName = [addressName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *components = [addressName componentsSeparatedByString:@":"];
        if(components.count >= 2) {
            options.hostAddress = components[0];
            options.hostPort = (uint16_t)[components[1] intValue];
        }else {
            options.hostAddress = addressName;
            options.hostPort = 0;
        }
    }
    self.launchOptions = options;
}

- (void)addWindowGestureRegcognizer {
//    return;
    NSArray *windows = [[NSApplication sharedApplication] windows];
    for (NSWindow * window in windows) {
        if([window isKindOfClass:[ADHMacWindow class]]){
            continue;
        }
        NSView *contentView = window.contentView;
        if(!contentView) {
            continue;
        }
        NSArray * gestureRecognizers = contentView.gestureRecognizers;
        BOOL isExists = NO;
        for (NSGestureRecognizer * recognizer in gestureRecognizers) {
            if([recognizer isKindOfClass:[ADHMacGestureRecognizer class]]){
                isExists = YES;
                break;
            }
        }
        if(!isExists){
            ADHMacGestureRecognizer * recognizer = [[ADHMacGestureRecognizer alloc] initWithTarget:self action:@selector(clickGestureRecognized:)];
            recognizer.numberOfClicksRequired = 2;
            recognizer.delegate = self;
            [contentView addGestureRecognizer:recognizer];
        }

    }
}

//(10_11)
- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event {
    if(event.type != NSEventTypeLeftMouseDown) {
        return NO;
    }
    NSEventModifierFlags flags = [event modifierFlags];
    //cmd和ctrl同时按下
    BOOL pass = (flags & NSEventModifierFlagCommand) && (flags & NSEventModifierFlagControl);
    return pass;
}

- (void)clickGestureRecognized: (NSGestureRecognizer *)recognizer {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    NSEventModifierFlags flags = [event modifierFlags];
    //cmd和ctrl同时按下
    BOOL pass = (flags & NSEventModifierFlagCommand) && (flags & NSEventModifierFlagControl);
    if(pass) {
        [self showMainView];
    }
}

- (BOOL)isUIShowing {
    return (self.mWindow && self.mWindow.visible);
}

- (void)showMainView {
    if(!self.mWindow) {
        ADHMacWindow *window = [[ADHMacWindow alloc] init];
        window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled;
        ADHMacConnectViewController *vc = [[ADHMacConnectViewController alloc] initWithNibName:@"ADHMacConnectViewController" bundle:[self adhBundle]];
        window.contentViewController = vc;
        window.title = @"Woodpecker";
        window.releasedWhenClosed = NO;
        self.mWindow = window;
    }
    //已经在展示
    if(self.mWindow.visible) {
        [self.mWindow orderFront:nil];
        [self.mWindow center];
    }else {
        [self.mWindow center];
        [self.mWindow makeKeyAndOrderFront:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kADHOrganizerWindowDidVisible object:self];
    }
}

- (void)showUI {
    [self showMainView];
}

- (ADHProtocol *)protocol {
    return self.mProtocol;
}

- (ADHDispatcher *)dispatcher {
    return self.mDispatcher;
}

- (ADHAppConnector *)connector {
    return self.mConnector;
}

- (void)setup {
    ADHProtocol *protocol = [ADHProtocol protocol];
    self.mProtocol = protocol;
    
    ADHAppConnector * connector = [[ADHAppConnector alloc] init];
    connector.socketIODelegate = self.mProtocol.socketChannel;
    self.mConnector = connector;
    
    ADHDispatcher * dispatcher = [[ADHDispatcher alloc] init];
    self.mDispatcher = dispatcher;
    [self registerServerService:dispatcher];
    
    ADHApiClient * apiClient = [ADHApiClient sharedApi];
    [apiClient setProtocol:self.mProtocol];
    [apiClient setDispatcher:self.mDispatcher];
    
    [self addWindowGestureRegcognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWindowGestureRegcognizer) name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusUpdate:) name:kADHConnectorConnectStatusUpdate object:nil];
    //尝试自动连接
    [self performSelector:@selector(tryAutoConnect) withObject:nil afterDelay:ADHOrganizerAutoConnectDelay];
    
    [[ADHKeepAliveService service] start];
}

- (void)registerServerService: (ADHDispatcher *)dispatcher {
    [dispatcher registerService:[ADHMetaService class]];
    [dispatcher registerService:[ADHFileBrowserActionService class]];
    [dispatcher registerService:[ADHAppDefaultActionService class]];
    [dispatcher registerService:[ADHAppInfoActionService class]];
    [dispatcher registerService:[ADHUserDefaultsActionService class]];
    [dispatcher registerService:[ADHAppBundleActionService class]];
    [dispatcher registerService:[ADHLocalizationActionService class]];
    [dispatcher registerService:[ADHNotificationActionService class]];
    [[ADHNotificationObserver sharedObserver] start];
    [dispatcher registerService:[ADHNetworkActionService class]];
    [dispatcher registerService:[ADHConsoleActionService class]];
}

/**
 plugin support
 */
- (void)registerService: (Class)serviceClazz {
    [self.mDispatcher registerService:serviceClazz];
}

- (void)onConnectionStatusUpdate:(NSNotification *)noti {
    [self updateProtocolSocket];
    if(![self.mConnector isSocketConnected]){
        //        NSLog(@"unconnected -_-");
        //unconnect
        NSDictionary *userInfo = noti.userInfo;
        NSError *err = userInfo[NSUnderlyingErrorKey];
        if(err && err.code == 7) {
            //if another endport closed, do not try to recover.
            [self clearAutoConnectTry];
        }else {
            [self doTryRecoverConnection];
        }
    }else if([self.mConnector isSocketConnected]){
        //        NSLog(@"connected ^_^");
        //connected
        self.workingHost = self.mConnector.connectedHost;
        self.workingPort = self.mConnector.connectedPort;
        self.tryRecoverConnectionCounter = 0;
        self.shouldTryRecoverConnection = YES;
    }
    __weak typeof(self) wself = self;
    /**
     * 添加延时
     * 目前如果app和mac同时在连接成功时发送请求会导致某一方失败
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kADHOrganizerWorkStatusUpdate object:wself userInfo:nil];
    });
}

- (void)updateProtocolSocket {
    if([self.mConnector isSocketConnected]){
        ADHGCDAsyncSocket * clientSocket = [self.mConnector socket];
        [self.mProtocol setSocket:clientSocket];
    }else{
        [self.mProtocol setSocket:nil];
    }
}

/**
 自动连接
 根据上次连接状态进行操作
 
 如果上次关闭，则不自动链接
 如果自动链接，
 1.如果上次为手动地址，连接手动地址
 2.如果为自动检测，则本次也自动检测，并在检测到时自动连接
 */
- (void)tryAutoConnect {
    [self loadLaunchOptions];
    adhDebugLog(@"开始尝试自动链接");
    ADHLaunchOptions *launchOptions = self.launchOptions;
    if(!launchOptions.autoConnectEnabled) {
        adhDebugLog(@"用户不允许自动连接");
        return;
    }
    adhDebugLog(@"开始自动连接");
    //标记当前正在自动链接过程
    self.bLaunchAutoConnectRoutine = YES;
    if([launchOptions isHostAddressValid]){
        NSString * host = launchOptions.hostAddress;
        uint16_t port = launchOptions.hostPort;
        adhDebugLog(@"用户设置了address: %@:%d,尝试链接",host,port);
        [self tryConnectToHost:host port:port];
    }else{
        adhDebugLog(@"开始搜索...");
        [self.mConnector startSearchServiceWithUpdateBlock:^(NSArray<ADHRemoteService *> *serviceList, BOOL moreComing) {
            if([self.mConnector isSocketConnected] || [self.mConnector isConnecting]) {
                return;
            }
            if(serviceList.count == 0){
                return;
            }
            if([launchOptions isHostNameValid]) {
                ADHRemoteService *targetService = nil;
                //查找用户设置的hostName
                NSString *hostName = launchOptions.hostName;
                for (ADHRemoteService *service in serviceList) {
                    if([service.name rangeOfString:hostName options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        targetService = service;
                        break;
                    }
                }
                if(targetService) {
                    adhDebugLog(@"找到: %@，尝试连接",hostName);
                    [self tryConnectToHost:targetService.host port:targetService.port];
                }else {
                    if(!moreComing) {
                        //没有找到符合，让用户处理
                        adhDebugLog(@"没有找到: %@",hostName);
                        [self handleLaunchAutoConnectFailed];
                    }
                }
            }else {
                /**
                 * 没有设置偏好host逻辑：
                 * 一直搜索直到搜索完毕，根据有多少service进行处理
                 * 只有一个则自动链接，多余一个弹出UI让用户选择，没有也弹出框让用户处理
                 */
                if(!moreComing) {
                    adhDebugLog(@"找到%zd个服务",serviceList.count);
                    if(serviceList.count == 1) {
                        //只有一个，自动链接
                        adhDebugLog(@"尝试自动连接");
                        ADHRemoteService *targetService = serviceList[0];
                        [self tryConnectToHost:targetService.host port:targetService.port];
                    }else {
                        //0个或多个，让用户手动处理
                        adhDebugLog(@"找到%zd个服务",serviceList.count);
                        [self handleLaunchAutoConnectFailed];
                    }
                }
            }
        } error:^(NSError *error) {
            adhDebugLog(@"%@",error);
            //目前暂未测试到超时（超时时间不确定）
            [self handleLaunchAutoConnectFailed];
        }];
    }
}

//1.1.7用户较多反馈，连接失败不弹出UI
- (void)handleLaunchAutoConnectFailed {

}

- (void)tryConnectToHost: (NSString *)host port: (uint16_t)port {
    [self.connector connectToRemoteHost:host port:port successBlock:^(ADHGCDAsyncSocket *socket) {
        
    } errorBlock:^(NSError *error) {
        adhDebugLog(@"连接失败：%@",error.localizedDescription);
        if(self.bLaunchAutoConnectRoutine) {
            [self handleLaunchAutoConnectFailed];
        }
    }];
}

- (void)doTryRecoverConnection {
    if(self.shouldTryRecoverConnection) {
        self.bLaunchAutoConnectRoutine = NO;
        if(self.workingHost.length > 0 && self.workingPort > 0){
            if(![self.connector isSocketConnected] && ![self.connector isConnecting]){
                self.tryRecoverConnectionCounter++;
                if(self.tryRecoverConnectionCounter <= ADHOrganizerAutoRecoverConnectionMaxCount){
                    [self tryConnectToHost:self.workingHost port:self.workingPort];
                    self.shouldTryRecoverConnection = NO;
                    //                    NSLog(@"try recover connenction %zd",self.tryRecoverConnectionCounter);
                }else{
                    [self clearAutoConnectTry];
                    //                    NSLog(@"extend max try recover connenction times %zd",ADHOrganizerAutoRecoverConnectionMaxCount);
                }
            }
        }
    }
}

//停止尝试自动连接
- (void)clearAutoConnectTry {
    self.shouldTryRecoverConnection = NO;
    self.workingPort = 0;
    self.workingHost = nil;
}


- (NSBundle *)adhBundle {
    NSString * bundlePath = [[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"WoodpeckerMacOS.framework"];
    NSBundle * bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}

- (BOOL)isWorking {
    return [self.connector isSocketConnected];
}


@end
